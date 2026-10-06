Attribute VB_Name = "MotorcycleGltfExport"
'==============================================================================
' MotorcycleGltfExport - export every assembly to glTF
'
' Generated 2026-09-19
'
' WHAT IT DOES
'   Opens each of the 37 assemblies in the project and saves it as .gltf
'   into:  C:\Users\micheal\Downloads\motorcyle\frame\Assembly\exploded
'   The folder is created if it does not exist. Output files are named
'   after the assembly, with subfolder names flattened using '__' so
'   nothing collides.
'
'   Source .SLDASM files are opened READ-ONLY and never saved, so this
'   cannot disturb your assemblies or the materials work.
'
' HOW SUCCESS IS JUDGED
'   By checking the .gltf file actually exists on disk afterwards, not by
'   the API return value - that is the mistake that cost us the material
'   run, and it is not getting repeated here.
'
' NOTE ON SPEED
'   motocycle_assembly1.SLDASM is about 63 MB and may take several
'   minutes on its own. The whole run will not be quick. The log is
'   written as it goes, so you can watch progress in the file.
'
' NOTE ON FORMAT
'   .gltf writes a JSON file plus companion .bin/texture files per
'   assembly. If you would rather have one self-contained file each,
'   change EXT below to "glb" and re-run.
'
' HOW TO USE
'   Tools > Macro > New..., File > Import File..., pick this .bas, DELETE
'   the boilerplate module, run Main.
'==============================================================================
Option Explicit

'--- settings ----------------------------------------------------------------
Private Const SRC_FOLDER As String = "C:\Users\micheal\Downloads\motorcyle\frame"
Private Const OUT_FOLDER As String = "C:\Users\micheal\Downloads\motorcyle\frame\Assembly\exploded"
Private Const LOG_FILE   As String = "gltf_export_log.txt"

' Output format: "gltf" (JSON + .bin companions) or "glb" (single file)
Private Const EXT As String = "gltf"

' True = list what would be exported, write nothing.
Private Const DRY_RUN As Boolean = False

'--- SolidWorks enums --------------------------------------------------------
Private Const cDocASSEMBLY      As Long = 2
Private Const cOpenSilent       As Long = 1
Private Const cOpenReadOnly     As Long = 2
Private Const cSaveCurrentVer   As Long = 0
Private Const cSaveSilent       As Long = 1

'--- state -------------------------------------------------------------------
Private swApp    As Object
Private mPaths() As String
Private mCount   As Long
Private mLog     As Integer
Private nOK As Long, nMissing As Long, nFailed As Long, nDry As Long


Sub Main()
    Dim i As Long

    Set swApp = Application.SldWorks
    If swApp Is Nothing Then
        MsgBox "Could not attach to SolidWorks.", vbCritical
        Exit Sub
    End If

    swApp.CloseAllDocuments True

'    make sure the output folder exists
    If Dir(OUT_FOLDER, vbDirectory) = "" Then
        On Error Resume Next
        MkDir OUT_FOLDER
        If Err.Number <> 0 Then
            MsgBox "Could not create output folder:" & vbCrLf & OUT_FOLDER & _
                   vbCrLf & vbCrLf & Err.Description, vbCritical
            Exit Sub
        End If
        On Error GoTo 0
    End If

    ReDim mPaths(0 To 200)
    mCount = 0

    mLog = FreeFile
    Open OUT_FOLDER & "\" & LOG_FILE For Output As #mLog
    WriteLog "MotorcycleGltfExport run " & Now
    WriteLog "format=" & EXT & "  DRY_RUN=" & DRY_RUN
    WriteLog "output: " & OUT_FOLDER
    WriteLog String(78, "-")

    LoadRows_01
    WriteLog "queued " & mCount & " assembly(ies)."
    WriteLog String(78, "-")

    For i = 0 To mCount - 1
        ExportOne mPaths(i)
    Next i

    WriteLog String(78, "-")
    WriteLog "exported=" & nOK & "  missing=" & nMissing & _
        "  failed=" & nFailed & "  skipped(dry run)=" & nDry
    Close #mLog

    MsgBox "Queued: " & mCount & vbCrLf & _
           "Exported: " & nOK & vbCrLf & _
           "Missing on disk: " & nMissing & vbCrLf & _
           "Failed: " & nFailed & vbCrLf & _
           "Skipped (dry run): " & nDry & vbCrLf & vbCrLf & _
           "Output: " & OUT_FOLDER, vbInformation, "glTF export"
End Sub


Private Sub ExportOne(ByVal relPath As String)
    Dim full As String, outName As String, outPath As String
    Dim swModel As Object
    Dim errs As Long, warns As Long

    full = SRC_FOLDER & "\" & relPath

    If Dir(full) = "" Then
        nMissing = nMissing + 1
        WriteLog "MISSING  " & relPath
        Exit Sub
    End If

'    flatten subfolders into the filename so nothing collides
    outName = relPath
    outName = Replace(outName, "\", "__")
    If InStrRev(outName, ".") > 0 Then outName = Left$(outName, InStrRev(outName, ".") - 1)
    outPath = OUT_FOLDER & "\" & outName & "." & EXT

    If DRY_RUN Then
        nDry = nDry + 1
        WriteLog "DRYRUN   " & relPath & "   -> " & outName & "." & EXT
        Exit Sub
    End If

'    read-only open - we never write to the source assembly
    Set swModel = swApp.OpenDoc6(full, cDocASSEMBLY, _
                                 cOpenSilent + cOpenReadOnly, "", errs, warns)
    If swModel Is Nothing Then
        nFailed = nFailed + 1
        WriteLog "OPENFAIL " & relPath & "   err=" & errs
        Exit Sub
    End If

    errs = 0: warns = 0
    On Error Resume Next
    Err.Clear
    swModel.Extension.SaveAs outPath, cSaveCurrentVer, cSaveSilent, Nothing, errs, warns
    If Err.Number <> 0 Then
        WriteLog "         (SaveAs raised err " & Err.Number & " - " & Err.Description & ")"
    End If
    Err.Clear
    On Error GoTo 0

'    judge by whether the file is actually on disk, not by a return value
    If Dir(outPath) <> "" Then
        nOK = nOK + 1
        WriteLog "OK       " & relPath & "   -> " & outName & "." & EXT
    Else
        nFailed = nFailed + 1
        WriteLog "NOFILE   " & relPath & "   errs=" & errs & " warns=" & warns
    End If

    swApp.CloseAllDocuments True
End Sub


Private Sub AddRow(ByVal relPath As String)
    If mCount > UBound(mPaths) Then ReDim Preserve mPaths(0 To mCount + 100)
    mPaths(mCount) = relPath
    mCount = mCount + 1
End Sub


Private Sub WriteLog(ByVal s As String)
    Print #mLog, s
    Debug.Print s
End Sub


'==============================================================================
' DATA - assemblies to export (37)
'==============================================================================
Private Sub LoadRows_01()
    AddRow "19_20mm and 30mm Ball Bearings\20mm_bearing.SLDASM"
    AddRow "19_20mm and 30mm Ball Bearings\30mm_bearing.SLDASM"
    AddRow "43_Engine Assembly\assemblyenginecase.SLDASM"
    AddRow "43_Engine Assembly\assemblyenginecaseuse.SLDASM"
    AddRow "Assembly\Assem3.SLDASM"
    AddRow "Assembly\camchainassembly_ed.SLDASM"
    AddRow "Assembly\camchainassembly_ed2.SLDASM"
    AddRow "Assembly\camchains_assembly.SLDASM"
    AddRow "Assembly\clutchhub-assembly.SLDASM"
    AddRow "Assembly\clutchhubassembly.SLDASM"
    AddRow "Assembly\crankshaft_assembly.SLDASM"
    AddRow "Assembly\engine_assembly.SLDASM"
    AddRow "Assembly\enginegearsassembly.SLDASM"
    AddRow "Assembly\enginehead_assembly.SLDASM"
    AddRow "Assembly\footrestandkickguard_assembly.SLDASM"
    AddRow "Assembly\footrestandkickguard_assembly_.SLDASM"
    AddRow "Assembly\footrestandkickguard_assembly_mirror.SLDASM"
    AddRow "Assembly\frontwheel_assembly.SLDASM"
    AddRow "Assembly\frontwheelframe_assembly.SLDASM"
    AddRow "Assembly\frontwheelframe_assembly_.SLDASM"
    AddRow "Assembly\gastankassembly.SLDASM"
    AddRow "Assembly\handbrake_assembly.SLDASM"
    AddRow "Assembly\handbrake_assembly_.SLDASM"
    AddRow "Assembly\headlight_assembly.SLDASM"
    AddRow "Assembly\piston assembly.SLDASM"
    AddRow "Assembly\rear foot rest front and mirror assembly.SLDASM"
    AddRow "Assembly\rear foot rest front assembly.SLDASM"
    AddRow "Assembly\rear foot rest front assembly_.SLDASM"
    AddRow "Assembly\rearlight_assembly.SLDASM"
    AddRow "Assembly\rearwheel_assembly.SLDASM"
    AddRow "Assembly\rearwheel_assembly_.SLDASM"
    AddRow "Assembly\rearwheel_frame_aseembly.SLDASM"
    AddRow "Assembly\shockabsorber_assembly.SLDASM"
    AddRow "Assembly\speedometer_assembly.SLDASM"
    AddRow "Assembly\wingmirror_assembly.SLDASM"
    AddRow "Assembly\wingmirror_mirror_assembly.SLDASM"
    AddRow "body\frameandbody.SLDASM"
End Sub

'==============================================================================
