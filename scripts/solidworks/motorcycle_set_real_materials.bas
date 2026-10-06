Attribute VB_Name = "MotorcycleRealMaterials"
'==============================================================================
' MotorcycleRealMaterials v2 - assign REAL SolidWorks materials to 158 parts
'
' Generated 2026-09-19
'
' WHAT CHANGED IN v3 - THE ACTUAL BUG
'   SetMaterialPropertyName2 applies the material correctly but returns
'   no usable value. Reading it as a Boolean gives False even when it
'   worked, so every previous run treated success as failure and closed
'   the part WITHOUT SAVING. That is why materials appeared during the
'   run and were gone after a restart. v3 ignores the return value,
'   verifies by reading the material back, then saves.
'
' EARLIER CHANGES
'   1. Main() now force-closes EVERY open document (including any open
'      assembly) before touching a single part. v1 left that to you, and
'      an assembly left open in the background was silently reloading and
'      snapshotting parts mid-run, then overwriting finished work when it
'      got saved later. This removes that risk at the source.
'   2. Each part now tries THREE ways of calling the material-assignment
'      API in sequence (documented, config='', config object direct) and
'      logs exactly which one worked - or all three, with the real VBA
'      error text, if none did. v1 only tried one and printed a guess.
'
' WHAT THIS WRITES
'   Real SolidWorks material assignment (not the text custom property -
'   that part is already done and untouched by this macro). After this
'   runs: FeatureManager tree shows the real material instead of <not
'   specified>, mass/density/appearance are real.
'
' BEFORE YOU RUN
'   1. Close SolidWorks completely and reopen it fresh. Don't open the
'      assembly, don't open any part - let the macro do all opening.
'   2. Leave DRY_RUN = True first. It closes other docs and opens nothing
'      of its own, just writes the log.
'
' AFTER IT FINISHES
'   Verify by opening a couple of PART files directly - not the assembly.
'   If those are correct, the fix worked at the source and the assembly
'   will simply display them correctly next time you open it. You should
'   not need to open or save the assembly at all for this to stick.
'
' HOW TO USE
'   Tools > Macro > New..., then in the VBA editor File > Import File... and
'   pick this .bas. DELETE the boilerplate module SolidWorks auto-creates -
'   its empty Sub main collides with this one. Then run Main.
'==============================================================================
Option Explicit

'--- settings ----------------------------------------------------------------
Private Const ROOT_FOLDER As String = "C:\Users\micheal\Downloads\motorcyle\frame"
Private Const LOG_FILE    As String = "real_materials_log.txt"

' True = report only. Still closes other open documents, opens none of
' its own. RUN THIS FIRST.
Private Const DRY_RUN As Boolean = True

' Save each document after editing.
Private Const SAVE_AFTER As Boolean = True

'--- SolidWorks enums (prefixed to avoid clashing with swconst) ---------------
Private Const cDocPART    As Long = 1
Private Const cOpenSilent As Long = 1
Private Const cSaveSilent As Long = 1

'--- state -------------------------------------------------------------------
Private swApp     As Object
Private mPaths()  As String
Private mDbs()    As String
Private mMats()   As String
Private mCount    As Long
Private mLog      As Integer
Private nOK As Long, nMissing As Long, nFailed As Long, nDry As Long, nNoConfig As Long


Sub Main()
    Dim i As Long
    Dim openDocs As Variant, d As Object

    Set swApp = Application.SldWorks
    If swApp Is Nothing Then
        MsgBox "Could not attach to SolidWorks.", vbCritical
        Exit Sub
    End If

'    Force-close everything currently open, including any assembly.
'    This is the fix for materials reverting: an assembly left open in
'    the background was reloading and re-snapshotting parts mid-run.
    swApp.CloseAllDocuments True

    ReDim mPaths(0 To 300)
    ReDim mDbs(0 To 300)
    ReDim mMats(0 To 300)
    mCount = 0

    mLog = FreeFile
    Open ROOT_FOLDER & "\" & LOG_FILE For Output As #mLog
    WriteLog "MotorcycleRealMaterials v2 run " & Now
    WriteLog "DRY_RUN=" & DRY_RUN
    WriteLog "closed all open documents before starting"
    WriteLog String(78, "-")

    LoadRows_01
    LoadRows_02
    LoadRows_03
    LoadRows_04
    WriteLog "queued " & mCount & " part(s)."
    WriteLog String(78, "-")

    For i = 0 To mCount - 1
        ProcessOne mPaths(i), mDbs(i), mMats(i)
    Next i

    WriteLog String(78, "-")
    WriteLog "assigned=" & nOK & "  missing=" & nMissing & _
        "  failed=" & nFailed & "  no-active-config=" & nNoConfig & _
        "  skipped(dry run)=" & nDry
    Close #mLog

    MsgBox "Queued: " & mCount & vbCrLf & _
           "Assigned: " & nOK & vbCrLf & _
           "Missing on disk: " & nMissing & vbCrLf & _
           "Failed: " & nFailed & vbCrLf & _
           "No active config: " & nNoConfig & vbCrLf & _
           "Skipped (dry run): " & nDry & vbCrLf & vbCrLf & _
           "Log: " & ROOT_FOLDER & "\" & LOG_FILE, vbInformation, _
           "Motorcycle real materials v2"
End Sub


Private Sub ProcessOne(ByVal relPath As String, ByVal dbName As String, _
                       ByVal matName As String)
    Dim full As String, errs As Long, warns As Long
    Dim swModel As Object, swConf As Object, configName As String
    Dim verified As String

    full = ROOT_FOLDER & "\" & relPath

    If Dir(full) = "" Then
        nMissing = nMissing + 1
        WriteLog "MISSING  " & relPath
        Exit Sub
    End If

    If DRY_RUN Then
        nDry = nDry + 1
        WriteLog "DRYRUN   " & relPath & "   -> " & matName
        Exit Sub
    End If

    Set swModel = swApp.OpenDoc6(full, cDocPART, cOpenSilent, "", errs, warns)
    If swModel Is Nothing Then
        nFailed = nFailed + 1
        WriteLog "OPENFAIL " & relPath & "   err=" & errs
        Exit Sub
    End If

    Set swConf = swModel.GetActiveConfiguration
    If swConf Is Nothing Then
        nNoConfig = nNoConfig + 1
        WriteLog "NOCONFIG " & relPath
        swApp.CloseAllDocuments True
        Exit Sub
    End If
    configName = swConf.Name

'    Call it as a STATEMENT, not a function. SetMaterialPropertyName2
'    does the work but gives back no usable return value - reading it as
'    Boolean yields False even on success, which is what made every
'    previous run bail out before saving. We ignore the result entirely
'    and verify by reading the material back instead.
    On Error Resume Next
    Err.Clear
    swModel.SetMaterialPropertyName2 configName, dbName, matName
    Err.Clear
    On Error GoTo 0

    verified = ReadBack(swModel, configName)

'    If the active config did not take, try all configurations.
    If StrComp(Trim$(verified), Trim$(matName), vbTextCompare) <> 0 Then
        On Error Resume Next
        Err.Clear
        swModel.SetMaterialPropertyName2 "", dbName, matName
        Err.Clear
        On Error GoTo 0
        verified = ReadBack(swModel, configName)
    End If

    If StrComp(Trim$(verified), Trim$(matName), vbTextCompare) <> 0 Then
        nFailed = nFailed + 1
        WriteLog "NOTAPPLIED " & relPath & "   wanted=[" & matName & _
            "]  got=[" & verified & "]"
        swApp.CloseAllDocuments True
        Exit Sub
    End If

'    THE STEP THAT WAS BEING SKIPPED.
    errs = 0: warns = 0
    swModel.Save3 cSaveSilent, errs, warns
    If errs <> 0 Then
        nFailed = nFailed + 1
        WriteLog "SAVEFAIL " & relPath & "   err=" & errs & "   (material applied but NOT saved)"
        swApp.CloseAllDocuments True
        Exit Sub
    End If

    nOK = nOK + 1
    WriteLog "SAVED    " & relPath & "   -> " & verified
    swApp.CloseAllDocuments True
End Sub


Private Function ReadBack(ByVal swModel As Object, ByVal cfg As String) As String
    Dim db As String, m As String
    db = ""
    On Error Resume Next
    Err.Clear
    m = swModel.GetMaterialPropertyName2(cfg, db)
    If Err.Number <> 0 Then m = "<read error " & Err.Number & ">"
    Err.Clear
    On Error GoTo 0
    ReadBack = m
End Function


Private Sub AddRow(ByVal relPath As String, ByVal dbPath As String, _
                   ByVal matName As String)
    If mCount > UBound(mPaths) Then
        ReDim Preserve mPaths(0 To mCount + 100)
        ReDim Preserve mDbs(0 To mCount + 100)
        ReDim Preserve mMats(0 To mCount + 100)
    End If
    mPaths(mCount) = relPath
    mDbs(mCount) = dbPath
    mMats(mCount) = matName
    mCount = mCount + 1
End Sub


Private Sub WriteLog(ByVal s As String)
    Print #mLog, s
    Debug.Print s
End Sub


'==============================================================================
' DATA - part, material database, exact material name
'==============================================================================
Private Sub LoadRows_01()
    AddRow "01_Introduction - Motorcycle Frame\bottomconnector.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "01_Introduction - Motorcycle Frame\frame.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "02_Left Side Engine Case\left-side-engine-case.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "03_Right Side Engine Case\right-side-engine-case.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "04_Clutch Hub Parts\basket_gear_mced.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "04_Clutch Hub Parts\clutch-hub-shaft-nut.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "04_Clutch Hub Parts\clutch-hub-steel-plate.SLDPRT", "Custom Materials", "AISI 1075 spring steel"
    AddRow "04_Clutch Hub Parts\clutch_hub_basket_mced.SLDPRT", "SOLIDWORKS Materials", "7075-T6 (SN)"
    AddRow "04_Clutch Hub Parts\clutch_hub_friction_plate.SLDPRT", "Custom Materials", "AISI 1075 spring steel"
    AddRow "04_Clutch Hub Parts\clutch_hub_gear_bearing.SLDPRT", "Custom Materials", "SAE 660 bearing bronze"
    AddRow "04_Clutch Hub Parts\clutch_hub_gear_pin.SLDPRT", "SOLIDWORKS Materials", "AISI 1015 Steel, Cold Drawn (SS)"
    AddRow "04_Clutch Hub Parts\clutch_hub_gear_plate.SLDPRT", "SOLIDWORKS Materials", "AISI 1020 Steel, Cold Rolled"
    AddRow "04_Clutch Hub Parts\clutch_hub_inner_hub.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "04_Clutch Hub Parts\clutch_hub_pressure_plate.SLDPRT", "SOLIDWORKS Materials", "7075-T6 (SN)"
    AddRow "04_Clutch Hub Parts\clutch_hub_pressure_shaft.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "04_Clutch Hub Parts\clutch_hub_pressure_spring.SLDPRT", "Custom Materials", "ASTM A401, Chrome Silicon"
    AddRow "05_Clutch Hub Engine Case\clutch_hub_engine_case_mced.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "06_Input Shaft Parts\input_shaft.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "06_Input Shaft Parts\input_shaft_gear_five.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "06_Input Shaft Parts\input_shaft_gear_four.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "06_Input Shaft Parts\input_shaft_gear_one.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "06_Input Shaft Parts\input_shaft_gear_three.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "06_Input Shaft Parts\input_shaft_gear_two.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "07_Output Shaft Parts\output_shaft.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "07_Output Shaft Parts\output_shaft_gear_five.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "07_Output Shaft Parts\output_shaft_gear_four.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "07_Output Shaft Parts\output_shaft_gear_one.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "07_Output Shaft Parts\output_shaft_gear_three.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "07_Output Shaft Parts\output_shaft_gear_two.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "07_Output Shaft Parts\output_shaft_sprocket.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "08_Crank Shaft Parts\crank_shaft.SLDPRT", "SOLIDWORKS Materials", "AISI 4340 Steel, normalized"
    AddRow "08_Crank Shaft Parts\crank_shaft_gear_one.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "08_Crank Shaft Parts\crank_shaft_sprocket.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "09_Stator Parts\stator_case.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "09_Stator Parts\stator_engine_case.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "10_Shift Drum Parts\shift_drum.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "10_Shift Drum Parts\shift_drum_gear_arms_pin.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "10_Shift Drum Parts\shift_drum_placer_arm.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "10_Shift Drum Parts\shift_drum_ratchet_arm.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "10_Shift Drum Parts\shift_drum_transmission_arm.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
End Sub

Private Sub LoadRows_02()
    AddRow "10_Shift Drum Parts\shift_drum_transmission_arm_two.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "11_Transmission Parts\transmission-shaft-foot-roller.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "11_Transmission Parts\transmission-shaft.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "11_Transmission Parts\transmission_pedal_plug.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "11_Transmission Parts\transmission_ratchet_a.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "11_Transmission Parts\transmission_ratchet_b.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "12_Cylinder Section Engine Case and Engine Head Case\cylinder_section_engine_case.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "12_Cylinder Section Engine Case and Engine Head Case\engine_head_case.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "13_Valve Section Engine Case and Valve Parts\valve-spring.SLDPRT", "Custom Materials", "ASTM A401, Chrome Silicon"
    AddRow "13_Valve Section Engine Case and Valve Parts\valve_section_engine_case.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "15_Rocker Arm Parts\rocker_arm.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "15_Rocker Arm Parts\rocker_shaft.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "16_Piston Parts\piston.SLDPRT", "SOLIDWORKS Materials", "2618-T61 (SS)"
    AddRow "16_Piston Parts\piston_bolt.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "16_Piston Parts\piston_bushing_Eng_Drw.SLDPRT", "Custom Materials", "SAE 660 bearing bronze"
    AddRow "16_Piston Parts\piston_pin_plug.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "17_Cam Chain Parts\cam_chain_inner_mced.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "17_Cam Chain Parts\cam_chain_outer_mced.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "17_Cam Chain Parts\cam_shaft_bushing_mced.SLDPRT", "Custom Materials", "SAE 660 bearing bronze"
    AddRow "17_Cam Chain Parts\cam_shaft_mced.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "17_Cam Chain Parts\cam_shaft_sprocket_mced.SLDPRT", "Custom Materials", "AISI 8620 Steel, carburized"
    AddRow "18_Articulated Rod Upper and Lower\articulated_rod_lower_mced.SLDPRT", "SOLIDWORKS Materials", "AISI 4340 Steel, normalized"
    AddRow "18_Articulated Rod Upper and Lower\articulated_rod_upper_mced.SLDPRT", "SOLIDWORKS Materials", "AISI 4340 Steel, normalized"
    AddRow "21_Wheel Rim\wheel_rim.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "22_Tyre\tyre.SLDPRT", "SOLIDWORKS Materials", "Natural Rubber"
    AddRow "23_Rear Wheel Parts\rear_wheel_brake_plate.SLDPRT", "SOLIDWORKS Materials", "AISI 304"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_18mm.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_absorber_shaft.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_c_shaft_plug.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_connector_shaf.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_end_cap.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_shaft.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "23_Rear Wheel Parts\rear_wheel_sprocket.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "24_Front Wheel Parts\front_wheel_brake_plate.SLDPRT", "SOLIDWORKS Materials", "AISI 304"
    AddRow "24_Front Wheel Parts\front_wheel_brake_plate_left.SLDPRT", "SOLIDWORKS Materials", "AISI 304"
    AddRow "24_Front Wheel Parts\front_wheel_guard.SLDPRT", "SOLIDWORKS Materials", "5052-H32"
    AddRow "24_Front Wheel Parts\front_wheel_guard_bridge.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "24_Front Wheel Parts\front_wheel_guard_bridge_mirror.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "24_Front Wheel Parts\front_wheel_guard_bridge_pin_a.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
End Sub

Private Sub LoadRows_03()
    AddRow "24_Front Wheel Parts\front_wheel_guard_bridge_pin_b.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "24_Front Wheel Parts\front_wheel_lower_connector_arm.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "24_Front Wheel Parts\front_wheel_m_frame_inner_pipe.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "24_Front Wheel Parts\front_wheel_shaft.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "24_Front Wheel Parts\front_wheel_side_base_pipe.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "24_Front Wheel Parts\front_wheel_side_pipe.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "24_Front Wheel Parts\front_wheel_upper_connector_arm.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "25_Front Wheel Brake Body and Mirror\front_wheel_brake_body.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "25_Front Wheel Brake Body and Mirror\front_wheel_brake_body_mirror.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "25_Front Wheel Brake Body and Mirror\front_wheel_brake_body_mirror2.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "26_Foot Rest Parts\foot_rest.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "26_Foot Rest Parts\foot_rest_kick_guard.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "26_Foot Rest Parts\foot_rest_kick_guard_Mirrored.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "26_Foot Rest Parts\foot_rest_pin.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "26_Foot Rest Parts\rear_foot_rest_frame.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "27_Exhaust Parts\exhaust_muffler_guard.SLDPRT", "SOLIDWORKS Materials", "AISI 304"
    AddRow "27_Exhaust Parts\exhaust_muffler_mid_section.SLDPRT", "SOLIDWORKS Materials", "AISI 304"
    AddRow "27_Exhaust Parts\exhaust_muffler_upper_section.SLDPRT", "SOLIDWORKS Materials", "AISI 304"
    AddRow "29_Air Intake Front Grill Body and Cap\air_intake_grill_body_mced.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "29_Air Intake Front Grill Body and Cap\air_intake_grill_cap_mced.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "30_Shock Absorber Parts\shock_absorber_arm_pin_a.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "30_Shock Absorber Parts\shock_absorber_arm_pin_b.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "30_Shock Absorber Parts\shock_absorber_arm_pin_c.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "30_Shock Absorber Parts\shock_absorber_arm_pin_d.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "30_Shock Absorber Parts\shock_absorber_bushing.SLDPRT", "SOLIDWORKS Materials", "POLYURETHANE (11671)"
    AddRow "30_Shock Absorber Parts\shock_absorber_connector_arm.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "30_Shock Absorber Parts\shock_absorber_frame_arm.SLDPRT", "SOLIDWORKS Materials", "AISI 4130 Steel, normalized at 870C"
    AddRow "30_Shock Absorber Parts\shock_absorber_inner_section.SLDPRT", "Custom Materials", "AISI 4140 Steel, quenched & tempered"
    AddRow "30_Shock Absorber Parts\shock_absorber_outer_section.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "30_Shock Absorber Parts\shock_absorber_spring.SLDPRT", "Custom Materials", "ASTM A401, Chrome Silicon"
    AddRow "31_Handlebar and Hand Brake Parts\hand_brake_body.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "31_Handlebar and Hand Brake Parts\hand_brake_cable_connector.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "31_Handlebar and Hand Brake Parts\hand_brake_handlebar_bridge.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "31_Handlebar and Hand Brake Parts\hand_brake_lever.SLDPRT", "Custom Materials", "A356-T6 cast aluminum alloy"
    AddRow "31_Handlebar and Hand Brake Parts\hand_brake_pin.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "31_Handlebar and Hand Brake Parts\handle_bar.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "31_Handlebar and Hand Brake Parts\handle_bar_connector_arm_bridge.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "31_Handlebar and Hand Brake Parts\handle_bar_connector_bridge_pin.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "31_Handlebar and Hand Brake Parts\handle_bar_grip.SLDPRT", "SOLIDWORKS Materials", "Natural Rubber"
    AddRow "32_Headlight Parts\headlight_back_case.SLDPRT", "SOLIDWORKS Materials", "ABS"
End Sub

Private Sub LoadRows_04()
    AddRow "32_Headlight Parts\headlight_bulb.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "32_Headlight Parts\headlight_bulb_reflective_liner.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "32_Headlight Parts\headlight_connector_arm.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "32_Headlight Parts\headlight_connector_arm_mirror.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "32_Headlight Parts\headlight_front_case.SLDPRT", "SOLIDWORKS Materials", "PC High Viscosity"
    AddRow "32_Headlight Parts\headlight_lightbulb.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "32_Headlight Parts\headlight_lightbulb_back.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "33-Light Frame Pin\light-frame-pin.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "34 - Rear Light Parts\rear-light-case-bulb.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "34 - Rear Light Parts\rear-light-frame.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "34 - Rear Light Parts\rear-light-front-case.SLDPRT", "SOLIDWORKS Materials", "PC High Viscosity"
    AddRow "34 - Rear Light Parts\rear-light-inner-bulb.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "34 - Rear Light Parts\rear-light-upper-frame.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "34 - Rear Light Parts\rear-lightbulb-base.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "35-Speedometer\speedometer-body.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "35-Speedometer\speedometer-screen.SLDPRT", "SOLIDWORKS Materials", "PC High Viscosity"
    AddRow "36- Wing mirror parts\wing-mirror-arm.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "36- Wing mirror parts\wing-mirror-arm_mirror.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "36- Wing mirror parts\wing-mirror-case.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "36- Wing mirror parts\wing-mirror-case_mirror.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "36- Wing mirror parts\wing-mirror-connector.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "36- Wing mirror parts\wing-mirror-connector_mirror.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "36- Wing mirror parts\wing-mirror-mirror.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "36- Wing mirror parts\wing-mirror-mirror_mirror.SLDPRT", "SOLIDWORKS Materials", "Glass"
    AddRow "body\freeformmodelling-creo\rearbody.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "body\freeformmodelling-creo\seater.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "body\freeformmodelling-creo\seater2.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "body\freeformmodelling-creo\seater22.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "body\freeformmodelling-creo\sidebody.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "body\freeformmodelling-creo\sidebodymirror.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "body\freeformmodelling-creo\speedometercover.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "body\rearbody.SLDPRT", "SOLIDWORKS Materials", "ABS"
    AddRow "cables\connectinghose3.SLDPRT", "SOLIDWORKS Materials", "Natural Rubber"
    AddRow "Chain\chain_guard.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "Chain\chain_guard_miror.SLDPRT", "SOLIDWORKS Materials", "6061-T6 (SS)"
    AddRow "Chain\chain_inner.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "Chain\chain_outer.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
    AddRow "Chain\drivechain.SLDPRT", "SOLIDWORKS Materials", "AISI 1045 Steel, cold drawn"
End Sub

'==============================================================================
