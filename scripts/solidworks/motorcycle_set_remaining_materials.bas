Attribute VB_Name = "MotorcycleRemainingMaterials"
'==============================================================================
' MotorcycleRemainingMaterials - assign REAL SolidWorks materials to the parts
' that motorcycle_set_real_materials.bas (v3, 158 parts) never covered:
' bolts, bearings, spark plugs, intake/exhaust manifolds, gas tank, controller,
' stator magnets/nut, valve, piston pin, etc.
'
' Generated 2026-09-26. Same proven open -> set -> read back -> save logic as
' v3 (which logged assigned=158 failed=0).
'
' ALSO WRITES A "Mass" CUSTOM PROPERTY
'   Each part gets Mass = "SW-Mass@<file>.SLDPRT" (a live link, not a typed
'   number), so a drawing BOM can show a Mass column. With promoted
'   subassemblies those masses then show per part at the top level.
'   Set MASS_ON_ALL_PARTS = True to also add that link to EVERY part under
'   ROOT_FOLDER (the 158 from the earlier macro included) without touching
'   their materials.
'
' BEFORE YOU RUN
'   1. Close SolidWorks completely and reopen it fresh. Do not open anything.
'   2. Leave DRY_RUN = True first and check the log, then set it to False.
'
' HOW TO USE
'   Tools > Macro > New..., File > Import File... this .bas, delete the
'   auto-created boilerplate module, run Main.
'==============================================================================
Option Explicit

'--- settings ----------------------------------------------------------------
Private Const ROOT_FOLDER As String = "C:\Users\micheal\Downloads\motorcyle\frame"
Private Const LOG_FILE    As String = "remaining_materials_log.txt"

Private Const DRY_RUN As Boolean = True

' Add/refresh the "Mass" custom property on each part this macro assigns.
Private Const ADD_MASS_PROPERTY As Boolean = True

' Also add the "Mass" property to every other .SLDPRT under ROOT_FOLDER.
Private Const MASS_ON_ALL_PARTS As Boolean = False

'--- SolidWorks enums (prefixed to avoid clashing with swconst) ---------------
Private Const cDocPART          As Long = 1
Private Const cOpenSilent       As Long = 1
Private Const cSaveSilent       As Long = 1
Private Const cCustomInfoText   As Long = 30
Private Const cPropReplaceValue As Long = 2

Private Const SW_DB     As String = "SOLIDWORKS Materials"
Private Const CUSTOM_DB As String = "Custom Materials"

'--- state -------------------------------------------------------------------
Private swApp     As Object
Private mPaths()  As String
Private mDbs()    As String
Private mMats()   As String
Private mCount    As Long
Private mLog      As Integer
Private nOK As Long, nMissing As Long, nFailed As Long, nDry As Long, nNoConfig As Long
Private nMassOnly As Long


Sub Main()
    Dim i As Long

    Set swApp = Application.SldWorks
    If swApp Is Nothing Then
        MsgBox "Could not attach to SolidWorks.", vbCritical
        Exit Sub
    End If

    swApp.CloseAllDocuments True

    ReDim mPaths(0 To 100)
    ReDim mDbs(0 To 100)
    ReDim mMats(0 To 100)
    mCount = 0

    mLog = FreeFile
    Open ROOT_FOLDER & "\" & LOG_FILE For Output As #mLog
    WriteLog "MotorcycleRemainingMaterials run " & Now
    WriteLog "DRY_RUN=" & DRY_RUN & "  ADD_MASS_PROPERTY=" & ADD_MASS_PROPERTY & _
             "  MASS_ON_ALL_PARTS=" & MASS_ON_ALL_PARTS
    WriteLog String(78, "-")

    LoadRows_Fasteners
    LoadRows_Engine
    LoadRows_FrameBody
    WriteLog "queued " & mCount & " part(s)."
    WriteLog String(78, "-")

    For i = 0 To mCount - 1
        ProcessOne mPaths(i), mDbs(i), mMats(i)
    Next i

    If MASS_ON_ALL_PARTS Then
        WriteLog String(78, "-")
        WriteLog "mass-property pass over every part under " & ROOT_FOLDER
        MassWalk CreateObject("Scripting.FileSystemObject").GetFolder(ROOT_FOLDER)
    End If

    WriteLog String(78, "-")
    WriteLog "assigned=" & nOK & "  missing=" & nMissing & _
        "  failed=" & nFailed & "  no-active-config=" & nNoConfig & _
        "  skipped(dry run)=" & nDry & "  mass-only=" & nMassOnly
    Close #mLog

    MsgBox "Queued: " & mCount & vbCrLf & _
           "Assigned: " & nOK & vbCrLf & _
           "Missing on disk: " & nMissing & vbCrLf & _
           "Failed: " & nFailed & vbCrLf & _
           "No active config: " & nNoConfig & vbCrLf & _
           "Skipped (dry run): " & nDry & vbCrLf & _
           "Mass property only: " & nMassOnly & vbCrLf & vbCrLf & _
           "Log: " & ROOT_FOLDER & "\" & LOG_FILE, vbInformation, _
           "Motorcycle remaining materials"
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

'    Statement call, return value ignored - it is unusable (see v3 notes).
'    Verify by reading the material back instead.
    On Error Resume Next
    Err.Clear
    swModel.SetMaterialPropertyName2 configName, dbName, matName
    Err.Clear
    On Error GoTo 0

    verified = ReadBack(swModel, configName)

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

    If ADD_MASS_PROPERTY Then SetMassProperty swModel, full

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


' Links a file-level "Mass" property to the mass SolidWorks calculates.
Private Sub SetMassProperty(ByVal swModel As Object, ByVal fullPath As String)
    Dim cpm As Object, fileName As String
    fileName = Mid$(fullPath, InStrRev(fullPath, "\") + 1)
    Set cpm = swModel.Extension.CustomPropertyManager("")
    cpm.Add3 "Mass", cCustomInfoText, """SW-Mass@" & fileName & """", cPropReplaceValue
End Sub


' Adds the Mass property to every part under a folder, materials untouched.
Private Sub MassWalk(ByVal fld As Object)
    Dim f As Object, subFld As Object, rel As String
    Dim swModel As Object, errs As Long, warns As Long

    For Each f In fld.Files
        If LCase$(Right$(f.Name, 7)) = ".sldprt" And Left$(f.Name, 2) <> "~$" Then
            rel = Mid$(f.Path, Len(ROOT_FOLDER) + 2)
            If DRY_RUN Then
                WriteLog "DRYMASS  " & rel
            Else
                Set swModel = swApp.OpenDoc6(f.Path, cDocPART, cOpenSilent, "", errs, warns)
                If swModel Is Nothing Then
                    WriteLog "MASSOPENFAIL " & rel & "   err=" & errs
                Else
                    SetMassProperty swModel, f.Path
                    errs = 0: warns = 0
                    swModel.Save3 cSaveSilent, errs, warns
                    If errs <> 0 Then
                        WriteLog "MASSSAVEFAIL " & rel & "   err=" & errs
                    Else
                        nMassOnly = nMassOnly + 1
                        WriteLog "MASS     " & rel
                    End If
                    swApp.CloseAllDocuments True
                End If
            End If
        End If
    Next f

    For Each subFld In fld.SubFolders
        MassWalk subFld
    Next subFld
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
        ReDim Preserve mPaths(0 To mCount + 50)
        ReDim Preserve mDbs(0 To mCount + 50)
        ReDim Preserve mMats(0 To mCount + 50)
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

' Bolts, nuts, screws: 4140 Q&T, same as piston_bolt in the first macro
' (roughly property class 10.9).
Private Sub LoadRows_Fasteners()
    Const M As String = "AISI 4140 Steel, quenched & tempered"
    AddRow "04_Clutch Hub Parts\clutch_hub_pressure_bolt.SLDPRT", CUSTOM_DB, M
    AddRow "09_Stator Parts\stator_nut.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\bolt_cylinder_section_mced.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\bolt_engine_case_l_to_c_mced.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\bolt_engine_case_l_to_r_mced.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\bolt_front_wheel_frame_clamp_mced.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\bolt_head_case_mced.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\bolt_large_engine_case_l_to_r_mced.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\frame_engine_bolt.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\smallpressurebolt-4mm.SLDPRT", CUSTOM_DB, M
    AddRow "20_Bolts - Various\testscrew.SLDPRT", CUSTOM_DB, M
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_as_bolt.SLDPRT", CUSTOM_DB, M
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_shaft_bolt.SLDPRT", CUSTOM_DB, M
    AddRow "23_Rear Wheel Parts\rear_wheel_sprocket_bolt.SLDPRT", CUSTOM_DB, M
    AddRow "24_Front Wheel Parts\front_wheel_frame_shaft_bolt.SLDPRT", CUSTOM_DB, M
    AddRow "24_Front Wheel Parts\front_wheel_frame_shaft_boltdd.SLDPRT", CUSTOM_DB, M
    AddRow "24_Front Wheel Parts\front_wheel_side_pipe_top_bolt.SLDPRT", CUSTOM_DB, M
    AddRow "30_Shock Absorber Parts\shock_absorber_pin_a_bolt.SLDPRT", CUSTOM_DB, M
End Sub

Private Sub LoadRows_Engine()
'    Ball bearings: Chrome Stainless Steel is the library's closest to 52100.
    AddRow "19_20mm and 30mm Ball Bearings\20mm_bearing_balls_mced.SLDPRT", SW_DB, "Chrome Stainless Steel"
    AddRow "19_20mm and 30mm Ball Bearings\20mm_bearing_inner_ring_mced.SLDPRT", SW_DB, "Chrome Stainless Steel"
    AddRow "19_20mm and 30mm Ball Bearings\20mm_bearing_outer_ring_mced.SLDPRT", SW_DB, "Chrome Stainless Steel"
    AddRow "19_20mm and 30mm Ball Bearings\30mm_bearing_balls_mced.SLDPRT", SW_DB, "Chrome Stainless Steel"
    AddRow "19_20mm and 30mm Ball Bearings\30mm_bearing_inner_ring_mced.SLDPRT", SW_DB, "Chrome Stainless Steel"
    AddRow "19_20mm and 30mm Ball Bearings\30mm_bearing_outer_ring_mced.SLDPRT", SW_DB, "Chrome Stainless Steel"

'    Spark plug is one body; the steel shell dominates its mass.
    AddRow "14-Spark Plugs\Spark Plug.SLDPRT", SW_DB, "AISI 1020 Steel, Cold Rolled"
    AddRow "14-Spark Plugs\Spark Plug2.SLDPRT", SW_DB, "AISI 1020 Steel, Cold Rolled"

    AddRow "13_Valve Section Engine Case and Valve Parts\valve.SLDPRT", SW_DB, "Chrome Stainless Steel"
    AddRow "16_Piston Parts\piston_pin.SLDPRT", CUSTOM_DB, "AISI 8620 Steel, carburized"

'    No NdFeB/ferrite in the library; Cast Alloy Steel (7.3 g/cc) is close
'    to NdFeB density (~7.5 g/cc), so the mass comes out right.
    AddRow "09_Stator Parts\stator_magnets.SLDPRT", SW_DB, "Cast Alloy Steel"

'    Intake manifold: cast aluminium like the engine cases; the connector is
'    the rubber boot to the carb/filter. Exhaust manifold: 304 like the muffler.
    AddRow "Assembly\airintake_mandifold.SLDPRT", CUSTOM_DB, "A356-T6 cast aluminum alloy"
    AddRow "Assembly\airintake_connector.SLDPRT", SW_DB, "Natural Rubber"
    AddRow "Assembly\exhaust_mandifold.SLDPRT", SW_DB, "AISI 304"
End Sub

Private Sub LoadRows_FrameBody()
    AddRow "01_Introduction - Motorcycle Frame\frame_chassis.SLDPRT", SW_DB, "AISI 4130 Steel, normalized at 870C"
    AddRow "01_Introduction - Motorcycle Frame\rearbodysection.sldprt", SW_DB, "ABS"
    AddRow "23_Rear Wheel Parts\rear_wheel_frame_old.SLDPRT", SW_DB, "AISI 4130 Steel, normalized at 870C"

    AddRow "31_Handlebar and Hand Brake Parts\connectingcable.SLDPRT", SW_DB, "PVC 0.007 Plasticized"
    AddRow "31_Handlebar and Hand Brake Parts\connectingcable2.SLDPRT", SW_DB, "PVC 0.007 Plasticized"

'    Body panels follow the first macro's ABS convention.
    AddRow "body\freeformmodelling-creo\gastank.SLDPRT", SW_DB, "ABS"
    AddRow "body\freeformmodelling-creo\gastanklift.SLDPRT", SW_DB, "ABS"
    AddRow "body\freeformmodelling-creo\gastankv2.SLDPRT", SW_DB, "ABS"
    AddRow "body\freeformmodelling-creo\rearbody123.SLDPRT", SW_DB, "ABS"
    AddRow "body\freeformmodelling-creo\seater221.SLDPRT", SW_DB, "ABS"
    AddRow "body\seatrim.SLDPRT", SW_DB, "ABS"

    AddRow "controler\case.SLDPRT", SW_DB, "ABS"
    AddRow "controler\caseback.SLDPRT", SW_DB, "ABS"
    AddRow "controler\button1.SLDPRT", SW_DB, "ABS"
    AddRow "controler\button2.SLDPRT", SW_DB, "ABS"
    AddRow "controler\button3.SLDPRT", SW_DB, "ABS"
    AddRow "controler\buttonw.SLDPRT", SW_DB, "ABS"
    AddRow "controler\leds.SLDPRT", SW_DB, "PC High Viscosity"

'    Not assigned - unclear what these are. Fill in and uncomment if needed:
'    AddRow "99_Unsorted - Review\lswugpart2.SLDPRT", SW_DB, "?"
'    AddRow "99_Unsorted - Review\part.SLDPRT", SW_DB, "?"
'    AddRow "assembly drawings\Part1.SLDPRT", SW_DB, "?"
End Sub
