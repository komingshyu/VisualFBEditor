﻿'#########################################################
'#  VisualFBEditor.bas                                   #
'#  This file is part of VisualFBEditor                  #
'#  Authors: Xusinboy Bekchanov (bxusinboy@mail.ru)      #
'#           Liu XiaLin (LiuZiQi.HK@hotmail.com)         #
'#########################################################

'#define __USE_GTK__
#ifndef __USE_MAKE__
	'#define __USE_GTK3__
	#define _NOT_AUTORUN_FORMS_
#endif

#define APP_TITLE "Visual FB Editor"
#define VER_MAJOR "1"
#define VER_MINOR "3"
#define VER_PATCH "3"
Const VERSION    = VER_MAJOR + "." + VER_MINOR + "." + VER_PATCH
Const BUILD_DATE = __DATE__
Const SIGN       = APP_TITLE + " " + VERSION

On Error Goto AA

#define MEMCHECK 0
#define FILENUMCHECK 1
#define _L DebugPrint_ __LINE__ & ": " & __FILE__ & ": " & __FUNCTION__:

Declare Sub DebugPrint_(ByRef Msg As WString)

#include once "Main.bi"
#include once "Debug.bi"
#include once "Designer.bi"
#include once "frmOptions.bi"
#include once "frmGoto.bi"
#include once "frmFind.bi"
#include once "frmFindInFiles.bi"
#include once "frmProjectProperties.bi"
#include once "frmImageManager.bi"
#include once "frmParameters.bi"
#include once "frmAddIns.bi"
#include once "frmTools.bi"
#include once "frmAbout.bi"
#include once "TabWindow.bi"

Sub DebugPrint_(ByRef Msg As WString)
	Debug.Print Msg, True, False, False, False
End Sub

Sub StartDebuggingWithCompile(Param As Any Ptr)
'	ThreadsEnter
'	ChangeEnabledDebug False, True, True
'	ThreadsLeave
	If Compile("Run") Then RunWithDebug(0) Else ThreadsEnter: ChangeEnabledDebug True, False, False: ThreadsLeave
End Sub

Sub StartDebugging(Param As Any Ptr)
	ThreadsEnter
	ChangeEnabledDebug False, True, True
	ThreadsLeave
	RunWithDebug(0)
End Sub

Sub RunCmd(Param As Any Ptr)
	Dim As UString MainFile = GetMainFile()
	Dim As UString cmd
	Dim As WString Ptr Workdir, CmdL
	If Trim(MainFile) = "" OrElse Trim(MainFile) = ML("Untitled") Then MainFile = GetFullPath(*ProjectsPath & "\1", pApp->FileName)
	If OpenCommandPromptInMainFileFolder Then
		WLet(Workdir, GetFolderName(MainFile))
	Else
		WLet(Workdir, *CommandPromptFolder)
	End If
	#ifdef __USE_GTK__
		cmd = WGet(TerminalPath) & " --working-directory=""" & *Workdir & """"
		Shell(cmd)
	#else
		cmd = Environ("COMSPEC") & " /K cd /D """ & *Workdir & """"
		Dim As Integer pClass
		Dim SInfo As STARTUPINFO
		Dim PInfo As PROCESS_INFORMATION
		WLet(CmdL, cmd)
		SInfo.cb = Len(SInfo)
		SInfo.dwFlags = STARTF_USESHOWWINDOW
		SInfo.wShowWindow = SW_NORMAL
		pClass = CREATE_UNICODE_ENVIRONMENT Or CREATE_NEW_CONSOLE
		If CreateProcessW(Null, CmdL, ByVal Null, ByVal Null, False, pClass, Null, Workdir, @SInfo, @PInfo) Then
			CloseHandle(pinfo.hProcess)
			CloseHandle(pinfo.hThread)
		End If
		If CmdL Then Deallocate_( CmdL)
	#endif
	If WorkDir Then Deallocate_( WorkDir)
End Sub

Sub FindInFiles
	ThreadCounter(ThreadCreate_(@FindSub))
End Sub
Sub ReplaceInFiles
	ThreadCounter(ThreadCreate_(@ReplaceSub))
End Sub

Sub mClickUseDefine(Sender As My.Sys.Object)
	Dim As String MenuName = Sender.ToString
	If miUseDefine <> 0 Then miUseDefine->Checked = False
	Dim As Integer Pos1 = InStr(MenuName, ":")
	If Pos1 = 0 Then Pos1 = Len(MenuName)
	UseDefine = Mid(MenuName, Pos1 + 1)
	miUseDefine = Cast(MenuItem Ptr, @Sender)
	miUseDefine->Checked = True
End Sub

Sub mClickMRU(Sender As My.Sys.Object)
	If Sender.ToString = "ClearFiles" Then
		miRecentFiles->Clear
		miRecentFiles->Enabled = False
		MRUFiles.Clear
	ElseIf Sender.ToString = "ClearProjects" Then
		miRecentProjects->Clear
		miRecentProjects->Enabled = False
		MRUProjects.Clear
	ElseIf Sender.ToString = "ClearFolders" Then
		miRecentFolders->Clear
		miRecentFolders->Enabled = False
		MRUFolders.Clear
	ElseIf Sender.ToString = "ClearSessions" Then
		miRecentSessions->Clear
		miRecentSessions->Enabled = False
		MRUSessions.Clear
	Else
		OpenFiles GetFullPath(Sender.ToString)
	End If
End Sub

Sub mClickHelp(ByRef Sender As My.Sys.Object)
	HelpOption.CurrentPath = Cast(MenuItem Ptr, @Sender)->ImageKey
	HelpOption.CurrentWord = ""
	ThreadCounter(ThreadCreate_(@RunHelp, @HelpOption))
End Sub

Sub mClickTool(ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As UserToolType Ptr tt = mi->Tag
	If tt <> 0 Then tt->Execute
End Sub

Sub mClickWindow(ByRef Sender As My.Sys.Object)
	Dim As MenuItem Ptr mi = Cast(MenuItem Ptr, @Sender)
	If mi = 0 Then Exit Sub
	Dim As TabWindow Ptr tb = mi->Tag
	If tb <> 0 Then tb->SelectTab
End Sub

Sub mClick(Sender As My.Sys.Object)
	Select Case Sender.ToString
	Case "NewProject":                          NewProject
	Case "OpenProject":                         OpenProject
	Case "OpenFolder":                          OpenFolder
	Case "OpenSession":                         OpenSession
	Case "SaveProject":                         SaveProject ptvExplorer->SelectedNode
	Case "SaveProjectAs":                       SaveProject ptvExplorer->SelectedNode, True
	Case "SaveSession":                         SaveSession
	Case "CloseFolder":                         CloseFolder GetParentNode(ptvExplorer->SelectedNode)
	Case "CloseProject":                        CloseProject GetParentNode(ptvExplorer->SelectedNode)
	Case "New":                                 AddTab
	Case "Open":                                OpenProgram
	Case "Save":                                Save
	Case "Print":                               PrintThis
	Case "PrintPreview":                        PrintPreview
	Case "PageSetup":                           PageSetup
	Case "CommandPrompt":                       ThreadCounter(ThreadCreate_(@RunCmd))
	Case "AddFromTemplates":                    AddFromTemplates
	Case "AddFilesToProject":                   AddFilesToProject
	Case "RemoveFileFromProject":               RemoveFileFromProject
	Case "OpenProjectFolder":                   OpenProjectFolder
	Case "ProjectProperties":                   pfProjectProperties->RefreshProperties: pfProjectProperties->ShowModal *pfrmMain
	Case "SetAsMain":                           SetAsMain @Sender = miTabSetAsMain
	Case "ReloadHistoryCode":                   ReloadHistoryCode 
	Case "ProjectExplorer":                     ptabLeft->Tab(0)->SelectTab
	Case "PropertiesWindow":                    ptabRight->Tab(0)->SelectTab
	Case "EventsWindow":                        ptabRight->Tab(1)->SelectTab
	Case "ToolBox":                             ptabLeft->Tab(1)->SelectTab
	Case "OutputWindow":                        ptabBottom->Tab(0)->SelectTab
	Case "ErrorsWindow":                        ptabBottom->Tab(1)->SelectTab
	Case "FindWindow":                          ptabBottom->Tab(2)->SelectTab
	Case "ToDoWindow":                          ptabBottom->Tab(3)->SelectTab
	Case "ChangeLogWindow":                     ptabBottom->Tab(4)->SelectTab
	Case "ImmediateWindow":                     ptabBottom->Tab(5)->SelectTab
	Case "LocalsWindow":                        ptabBottom->Tab(6)->SelectTab
	Case "GlobalsWindow":                       ptabBottom->Tab(7)->SelectTab
	'Case "ProceduresWindow":                    ptabBottom->Tab(8)->SelectTab
	Case "ThreadsWindow":                       ptabBottom->Tab(8)->SelectTab
	Case "WatchWindow":                         ptabBottom->Tab(9)->SelectTab
	Case "ImageManager":                        pfImageManager->Show *pfrmMain
	Case "Toolbars":                            'ShowMainToolbar = Not ShowMainToolbar: ReBar1.Visible = ShowMainToolbar: pfrmMain->RequestAlign
	Case "Standard":                            ShowStandardToolBar = Not ShowStandardToolBar: ReBar1.Bands.Item(0)->Visible = ShowStandardToolBar: mnuStandardToolBar->Checked = ShowStandardToolbar: pfrmMain->RequestAlign
	Case "Edit":                                ShowEditToolBar = Not ShowEditToolBar: ReBar1.Bands.Item(1)->Visible = ShowEditToolBar: mnuEditToolBar->Checked = ShowEditToolbar: pfrmMain->RequestAlign
	Case "Project":                             ShowProjectToolBar = Not ShowProjectToolBar: ReBar1.Bands.Item(2)->Visible = ShowProjectToolBar: mnuProjectToolBar->Checked = ShowProjectToolbar: pfrmMain->RequestAlign
	Case "Build":                               ShowBuildToolBar = Not ShowBuildToolBar: ReBar1.Bands.Item(3)->Visible = ShowBuildToolBar: mnuBuildToolBar->Checked = ShowBuildToolbar: pfrmMain->RequestAlign
	Case "Run":                                 ShowRunToolBar = Not ShowRunToolBar: ReBar1.Bands.Item(4)->Visible = ShowRunToolBar: mnuRunToolBar->Checked = ShowRunToolbar: pfrmMain->RequestAlign
	Case "TBUseDebugger":                       ChangeUseDebugger tbtUseDebugger->Checked, 0
	Case "UseDebugger":                         ChangeUseDebugger Not mnuUseDebugger->Checked, 1
	Case "Folder":                              WithFolder
	Case "SyntaxCheck":                         If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@SyntaxCheck))
	Case "CompileAll":                          If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileAll))
	Case "Compile":                             If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileProgram))
	Case "Make":                                If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeExecute))
	Case "MakeClean":                           If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@MakeExecute))
	Case "BuildBundle":                         If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileBundle))
	Case "BuildAPK":                            If SaveAllBeforeCompile Then ThreadCounter(ThreadCreate_(@CompileAPK))
	Case "CreateKeyStore":                      CreateKeyStore
	Case "GenerateSignedBundle":                GenerateSignedBundleAPK("bundle")
	Case "GenerateSignedAPK":                   GenerateSignedBundleAPK("apk")
	Case "FormatProject":                       ThreadCounter(ThreadCreate_(@FormatProject)) 'FormatProject 0
	Case "UnformatProject":                     ThreadCounter(ThreadCreate_(@FormatProject, Cast(Any Ptr, 1))) 'FormatProject Cast(Any Ptr, 1)
	Case "ProjectNumberOn":                     ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectMacroNumberOn":                ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectMacroNumberOnStartsOfProcs":   ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectNumberOff":                    ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectPreprocessorNumberOn":         ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "ProjectPreprocessorNumberOff":        ThreadCounter(ThreadCreate_(@NumberingProject, @Sender))
	Case "Parameters":                          pfParameters->ShowModal *pfrmMain
	Case "GDBCommand":                          GDBCommand
	Case "StartWithCompile"
		If SaveAllBeforeCompile Then
			ChangeEnabledDebug False, True, True
			'SaveAll '
			Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
			If *CurrentDebugger = ML("Integrated GDB Debugger") Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					If iFlagStartDebug = 0 Then
						If UseDebugger Then
							runtype = RTFRUN
							CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
							ThreadCounter(ThreadCreate_(@StartDebuggingWithCompile))
						Else
							ThreadCounter(ThreadCreate_(@CompileAndRun))
						End If
					Else
						continue_debug
					End If
				#endif
			Else
				If InDebug Then
					#ifndef __USE_GTK__
						ChangeEnabledDebug False, True, True
						fastrun()
						'runtype = RTRUN
						'thread_rsm()
					#endif
				ElseIf UseDebugger Then
					#ifndef __USE_GTK__
						runtype = RTFRUN
						'runtype = RTRUN
						CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
					#endif
					ThreadCounter(ThreadCreate_(@StartDebuggingWithCompile))
				Else
					ThreadCounter(ThreadCreate_(@CompileAndRun))
				End If
			End If
		End If
	Case "Start"
		Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
		If *CurrentDebugger = ML("Integrated GDB Debugger") Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If iFlagStartDebug = 0 Then
					If UseDebugger Then
						runtype= RTFRUN
						CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
						ThreadCounter(ThreadCreate_(@StartDebugging))
					Else
						ThreadCounter(ThreadCreate_(@RunProgram))
					End If
				Else
					ChangeEnabledDebug False, True, True
					continue_debug()
				End If
			#endif
		Else
			If InDebug Then
				#ifndef __USE_GTK__
					ChangeEnabledDebug False, True, True
					fastrun()
	'				runtype = RTRUN
	'				thread_rsm()
				#endif
			ElseIf UseDebugger Then
				#ifndef __USE_GTK__
					runtype = RTFRUN
					'runtype = RTRUN
					CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
				#endif
				ThreadCounter(ThreadCreate_(@StartDebugging))
			Else
				ThreadCounter(ThreadCreate_(@RunProgram))
			End If
		End If
	Case "Break":
		#ifdef __USE_GTK__
			ChangeEnabledDebug True, False, True
		#else
			If runtype=RTFREE Or runtype=RTFRUN Then
				runtype=RTFRUN 'to treat free as fast
				For i As Integer = 1 To linenb 'restore every breakpoint
					WriteProcessMemory(dbghand,Cast(LPVOID,rline(i).ad),@breakcpu,1,0)
				Next
			Else
				runtype=RTSTEP:procad=0:procin=0:proctop=False:procbot=0
			EndIf
			stopcode=CSHALTBU
			'SetFocus(richeditcur)
		#endif
	Case "End":
		Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
		If *CurrentDebugger = ML("Integrated GDB Debugger") Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If Running Then
					kill_debug()
				Else
					command_debug "q"
				End If
			#endif
		Else
			#ifdef __USE_GTK__
				ChangeEnabledDebug True, False, False
			#else
				'kill_process("Terminate immediatly no saved data, other option Release")
				For i As Integer = 1 To linenb 'restore old instructions
					WriteProcessMemory(dbghand, Cast(LPVOID, rline(i).ad), @rline(i).sv, 1, 0)
				Next
				runtype = RTFREE
				'but_enable()
				thread_rsm()
				DeleteDebugCursor
				ChangeEnabledDebug True, False, False
			#endif
		End If
	Case "Restart"
		Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
		If *CurrentDebugger = ML("Integrated GDB Debugger") Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				command_debug("r")
			#endif
		Else
			#ifndef __USE_GTK__
				If prun AndAlso kill_process("Trying to launch but debuggee still running") = False Then
					Exit Sub
				End If
				runtype = RTFRUN
				'runtype = RTRUN
				CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
				Restarting = True
				ThreadCounter(ThreadCreate_(@StartDebugging))
			#endif
		End If
	Case "StepInto":
		ptabBottom->TabIndex = 6 'David Changed
		Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
		If *CurrentDebugger = ML("Integrated GDB Debugger") Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If iFlagStartDebug = 0 Then
					runtype = RTSTEP
					CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
					ThreadCounter(ThreadCreate_(@StartDebugging))
				Else
					step_debug("s")
				End If
			#endif
		Else
			If InDebug Then
				ChangeEnabledDebug False, True, True
				#ifndef __USE_GTK__
					stopcode=0
					'bcktrk_close
					SetFocus(windmain)
					thread_rsm
				#endif
			Else
				#ifndef __USE_GTK__
					runtype = RTSTEP
					CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
				#endif
				ThreadCounter(ThreadCreate_(@StartDebugging))
			End If
		End If
	Case "StepOver":
		Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
		If *CurrentDebugger = ML("Integrated GDB Debugger") Then
			#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
				If iFlagStartDebug = 0 Then
					CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
					ThreadCounter(ThreadCreate_(@StartDebugging))
				Else
					step_debug("n")
				End If
			#endif
		Else
			If InDebug Then
				ChangeEnabledDebug False, True, True
				#ifndef __USE_GTK__
					procin = procsk
					runtype = RTRUN
					SetFocus(windmain)
					thread_rsm()
				#endif
			Else
				#ifndef __USE_GTK__
					procin = procsk
					runtype = RTFRUN
					CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
				#endif
				ThreadCounter(ThreadCreate_(@StartDebugging))
			End If
		End If
	Case "SaveAs", "Close", "SyntaxCheck", "Compile", "CompileAndRun", "Run", "RunToCursor", "SplitHorizontally", "SplitVertically", _
		"Start", "Stop", "StepOut", "FindNext", "FindPrev", "Goto", "SetNextStatement", "SortLines", "SplitUp", "SplitDown", "SplitLeft", "SplitRight", _
		"AddWatch", "ShowVar", "NextBookmark", "PreviousBookmark", "ClearAllBookmarks", "Code", "Form", "CodeAndForm" '
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If tb = 0 Then Exit Sub
		Select Case Sender.ToString
		Case "Save":                        tb->Save
		Case "SaveAs":                      tb->SaveAs:  frmMain.Caption = tb->FileName & " - " & App.Title
		Case "Close":                       CloseTab(tb)
		Case "SortLines":                   tb->SortLines
		Case "SplitHorizontally":           tb->txtCode.SplittedHorizontally = Not mnuSplitHorizontally->Checked
		Case "SplitVertically":             tb->txtCode.SplittedVertically = Not mnuSplitVertically->Checked
		Case "SplitUp", "SplitDown", "SplitLeft", "SplitRight":
			Var ptabCode = Cast(TabControl Ptr, mnuTabs.ParentWindow)
			Var tb = Cast(TabWindow Ptr, ptabCode->SelectedTab)
			Var tp = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var ptabPanelNew = New TabPanel
			Var bUpDown = False
			Select Case Sender.ToString
			Case "SplitUp"
				ptabPanelNew->Align = DockStyle.alTop
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alTop
				bUpDown = True
			Case "SplitDown"
				ptabPanelNew->Align = DockStyle.alBottom
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alBottom
				bUpDown = True
			Case "SplitLeft"
				ptabPanelNew->Align = DockStyle.alLeft
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alLeft
			Case "SplitRight"
				ptabPanelNew->Align = DockStyle.alRight
				ptabPanelNew->splGroup.Align = SplitterAlignmentConstants.alRight
			End Select
			Var ptabPanel = Cast(TabPanel Ptr, tb->Parent->Parent)
			Var Idx = tp->IndexOf(tb->Parent)
			tp->Add ptabPanelNew, Idx
			tp->Add @ptabPanelNew->splGroup, Idx + 1
			Var SplitterCount = 0 'Fix(tp->ControlCount / 2)
			For i As Integer = 1 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					If tp->Controls[i]->Align = DockStyle.alTop OrElse tp->Controls[i]->Align = DockStyle.alBottom Then SplitterCount += 1
				Else
					If tp->Controls[i]->Align = DockStyle.alLeft OrElse tp->Controls[i]->Align = DockStyle.alRight Then SplitterCount += 1
				End If
			Next
			For i As Integer = 0 To tp->ControlCount - 2 Step 2
				If bUpDown Then
					tp->Controls[i]->Height = (tp->Height - ptabPanelNew->splGroup.Height * SplitterCount) / (SplitterCount + 1)
				Else
					tp->Controls[i]->Width = (tp->Width - ptabPanelNew->splGroup.Width * SplitterCount) / (SplitterCount + 1)
				End If
			Next
			ptabPanel->tabCode.DeleteTab tb
			tb->Parent = @ptabPanelNew->tabCode
			tb->ImageKey = tb->ImageKey
			ptabPanelNew->tabCode.Add @tb->btnClose
			tp->RequestAlign
			ptabCode = @ptabPanelNew->tabCode
			tabPanels.Add ptabPanelNew
		Case "SetNextStatement":
			Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
			If *CurrentDebugger = ML("Integrated GDB Debugger") Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					Dim As Integer iStartLine, iEndLine, iStartChar, iEndChar
					tb->txtCode.GetSelection iStartLine, iEndLine, iStartChar, iEndChar
					command_debug("jump " & Replace(tb->FileName, "\", "/") & ":" & Str(iEndLine))
				#endif
			Else
				#ifndef __USE_GTK__
					exe_mod()
				#endif
			End If
		Case "ShowVar":                 
			#ifndef __USE_GTK__
				var_tip(1)
			#endif
		Case "StepOut":
			Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
			If *CurrentDebugger = ML("Integrated GDB Debugger") Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					If iFlagStartDebug = 0 Then
						ThreadCounter(ThreadCreate_(@StartDebugging))
					Else
						step_debug("n")
					End If
				#endif
			Else
				#ifndef __USE_GTK__
					If InDebug Then
						ChangeEnabledDebug False, True, True
						If (threadcur<>0 AndAlso proc_find(thread(threadcur).id,KLAST)<>proc_find(thread(threadcur).id,KFIRST)) _
							OrElse (threadcur=0 AndAlso proc(procr(proc_find(thread(0).id,KLAST)).idx).nm<>"main") Then 'impossible to go out first proc of thread, constructore for shared 22/12/2015
							procad = procsv
							runtype = RTFRUN
						End If
						SetFocus(windmain)
						thread_rsm()
					End If
				#endif
			End If
		Case "RunToCursor":
			Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
			If *CurrentDebugger = ML("Integrated GDB Debugger") Then
				#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
					If iFlagStartDebug = 1 Then
						ChangeEnabledDebug False, True, True
						set_bp True
						continue_debug
					Else
						RunningToCursor = True
						CurrentTimer = SetTimer(0, 0, 1, Cast(Any Ptr, @TimerProcGDB))
						ThreadCounter(ThreadCreate_(@StartDebugging))
					End If
				#endif
			Else
				If InDebug Then
					ChangeEnabledDebug False, True, True
					#ifndef __USE_GTK__
						brk_set(9)
					#endif
				Else
					RunningToCursor = True
					runtype = RTFRUN
					#ifndef __USE_GTK__
						CurrentTimer = SetTimer(0, 0, 1, @TimerProc)
					#endif
					ThreadCounter(ThreadCreate_(@StartDebugging))
				End If
			End If
		Case "AddWatch":
			#ifndef __USE_GTK__
				var_tip(2)
			#endif
		Case "FindNext":                    pfFind->Find(True)
		Case "FindPrev":                    pfFind->Find(False)
		Case "Goto":                        pfGoto->Show *pfrmMain
		Case "NextBookmark":                NextBookmark 1
		Case "PreviousBookmark":            NextBookmark -1
		Case "ClearAllBookmarks":           ClearAllBookmarks
		Case "Code":                        tb->tbrTop.Buttons.Item("Code")->Checked = True: tbrTop_ButtonClick tb->tbrTop, *tb->tbrTop.Buttons.Item("Code")
		Case "Form":                        tb->tbrTop.Buttons.Item("Form")->Checked = True: tbrTop_ButtonClick tb->tbrTop, *tb->tbrTop.Buttons.Item("Form")
		Case "CodeAndForm":                 tb->tbrTop.Buttons.Item("CodeAndForm")->Checked = True: tbrTop_ButtonClick tb->tbrTop, *tb->tbrTop.Buttons.Item("CodeAndForm")
		End Select
	Case "SaveAll":                         SaveAll
	Case "CloseAll":                        CloseAllTabs
	Case "CloseAllWithoutCurrent":          CloseAllTabs(True)
	Case "Exit":                            pfrmMain->CloseForm
	Case "Find":                            mFormFind = True: pfFind->Show *pfrmMain
	Case "FindInFiles":                     mFormFindInFile = True:  pfFindFile->Show *pfrmMain
	Case "ReplaceInFiles":                  mFormFindInFile = False:  pfFindFile->Show *pfrmMain
	Case "Replace":                         mFormFind = False: pfFind->Show *pfrmMain
	Case "PinLeft":                         SetLeftClosedStyle Not tbLeft.Buttons.Item("PinLeft")->Checked, False
	Case "PinRight":                        SetRightClosedStyle Not tbRight.Buttons.Item("PinRight")->Checked, False
	Case "PinBottom":                       SetBottomClosedStyle Not tbBottom.Buttons.Item("PinBottom")->Checked, False
	Case "EraseOutputWindow":               txtOutput.Text = ""
	Case "EraseImmediateWindow":            txtImmediate.Text = ""
	Case "Update":                          
		#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
			iStateMenu = IIf(tbBottom.Buttons.Item("Update")->Checked, 2, 1): If Running = False Then command_debug("")
		#endif
	Case "AddForm":                         AddFromTemplate ExePath + "/Templates/Files/Form.frm"
	Case "AddModule":                       AddFromTemplate ExePath + "/Templates/Files/Module.bas"
	Case "AddIncludeFile":                  AddFromTemplate ExePath + "/Templates/Files/Include File.bi"
	Case "AddUserControl":                  AddFromTemplate ExePath + "/Templates/Files/User Control.bas"
	Case "AddResource":                     AddFromTemplate ExePath + "/Templates/Files/Resource.rc"
	Case "AddManifest":                     AddFromTemplate ExePath + "/Templates/Files/Manifest.xml"
	Case "PlainText", "Utf8", "Utf8BOM", "Utf16BOM", "Utf32BOM"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		Dim FileEncoding As FileEncodings
		Select Case Sender.ToString
		Case "PlainText": FileEncoding = FileEncodings.PlainText
		Case "Utf8": FileEncoding = FileEncodings.Utf8
		Case "Utf8BOM": FileEncoding = FileEncodings.Utf8BOM
		Case "Utf16BOM": FileEncoding = FileEncodings.Utf16BOM
		Case "Utf32BOM": FileEncoding = FileEncodings.Utf32BOM
		End Select
		ChangeFileEncoding FileEncoding
		If tb <> 0 Then
			tb->FileEncoding = FileEncoding
			tb->Modified = True
		End If
	Case "WindowsCRLF", "LinuxLF", "MacOSCR"
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		Dim NewLineType As NewLineTypes
		Select Case Sender.ToString
		Case "WindowsCRLF": NewLineType = NewLineTypes.WindowsCRLF
		Case "LinuxLF": NewLineType = NewLineTypes.LinuxLF
		Case "MacOSCR": NewLineType = NewLineTypes.MacOSCR
		End Select
		ChangeNewLineType NewLineType
		If tb <> 0 Then
			tb->NewLineType = NewLineType
			tb->Modified = True
		End If
		#ifndef __USE_GTK__
		Case "ShowString":                  string_sh(tviewvar)
		Case "ShowExpandVariable":          shwexp_new(tviewvar)
		#endif
	Case "Undo", "Redo", "Cut", "Copy", "Paste", "SelectAll", "Duplicate", "SingleComment", "BlockComment", "UnComment", _
		"Indent", "Outdent", "Format", "Unformat", "AddSpaces", "NumberOn", "MacroNumberOn", "NumberOff", "ProcedureNumberOn", "ProcedureMacroNumberOn", "ProcedureNumberOff", _
		"PreprocessorNumberOn", "PreprocessorNumberOff", "Breakpoint", "ToggleBookmark", "CollapseAll", "UnCollapseAll", _
		"CompleteWord", "ParameterInfo", "OnErrorResumeNext", "OnErrorGoto", "OnErrorGotoResumeNext", "RemoveErrorHandling", "Define"
		If pfrmMain->ActiveControl = 0 Then Exit Sub
		If pfrmMain->ActiveControl->ClassName <> "EditControl" AndAlso pfrmMain->ActiveControl->ClassName <> "TextBox" AndAlso pfrmMain->ActiveControl->ClassName <> "Panel" Then Exit Sub
		Dim tb As TabWindow Ptr = Cast(TabWindow Ptr, ptabCode->SelectedTab)
		If pfrmMain->ActiveControl->ClassName = "TextBox" Then
			Dim txt As TextBox Ptr = Cast(TextBox Ptr, pfrmMain->ActiveControl)
			Select Case Sender.ToString
			Case "Undo":                    txt->Undo
			Case "Cut":                     txt->CutToClipboard
			Case "Copy":                    txt->CopyToClipboard
			Case "Paste":                   txt->PasteFromClipboard
			Case "SelectAll":               txt->SelectAll
			End Select
		ElseIf tb <> 0 Then
			If tb->cboClass.ItemIndex > 0 Then
				Dim des As Designer Ptr = tb->Des
				If des = 0 Then Exit Sub
				Select Case Sender.ToString
				Case "Cut":                     des->CutControl
				Case "Copy":                    des->CopyControl
				Case "Paste":                   des->PasteControl
				Case "Delete":                  des->DeleteControl
				Case "Duplicate":               des->DuplicateControl
				Case "SelectAll":               des->SelectAllControls
				End Select
			ElseIf pfrmMain->ActiveControl->ClassName = "EditControl" OrElse pfrmMain->ActiveControl->ClassName = "Panel" Then
				Dim ec As EditControl Ptr = @tb->txtCode
				Select Case Sender.ToString
				Case "Redo":                    ec->Redo
				Case "Undo":                    ec->Undo
				Case "Cut":                     ec->CutToClipboard
				Case "Copy":                    ec->CopyToClipboard
				Case "Paste":                   ec->PasteFromClipboard
				Case "Duplicate":               ec->DuplicateLine
				Case "SelectAll":               ec->SelectAll
				Case "SingleComment":           ec->CommentSingle
				Case "BlockComment":            ec->CommentBlock
				Case "UnComment":               ec->UnComment
				Case "Indent":                  ec->Indent
				Case "Outdent":                 ec->Outdent
				Case "Format":                  ec->FormatCode
				Case "Unformat":                ec->UnformatCode
				Case "AddSpaces":               tb->AddSpaces
				Case "Breakpoint":
					Dim As WString Ptr CurrentDebugger = IIf(tbt32Bit->Checked, CurrentDebugger32, CurrentDebugger64)
					If *CurrentDebugger = ML("Integrated GDB Debugger") Then
						#if Not (defined(__FB_WIN32__) AndAlso defined(__USE_GTK__))
							If iFlagStartDebug = 1 Then
								set_bp
							End If
						#endif
					Else
						#ifndef __USE_GTK__
							If InDebug Then: brk_set(1): End If
						#endif
					End If
					ec->BreakPoint
				Case "CollapseAll":             ec->CollapseAll
				Case "UnCollapseAll":           ec->UnCollapseAll
				Case "CompleteWord":            CompleteWord
				Case "ParameterInfo":           ParameterInfo
				Case "ToggleBookmark":          ec->Bookmark
				Case "Define":                  tb->Define
				Case "NumberOn":        	    tb->NumberOn
				Case "MacroNumberOn":        	tb->NumberOn , , True
				Case "NumberOff":               tb->NumberOff
				Case "ProcedureNumberOn":       tb->ProcedureNumberOn
				Case "ProcedureMacroNumberOn":  tb->ProcedureNumberOn True
				Case "ProcedureNumberOff":      tb->ProcedureNumberOff
				Case "PreprocessorNumberOn":    tb->PreprocessorNumberOn
				Case "PreprocessorNumberOff":   tb->PreprocessorNumberOff
				Case "OnErrorResumeNext":       tb->SetErrorHandling "On Error Resume Next", ""
				Case "OnErrorGoto":             tb->SetErrorHandling "On Error Goto ErrorHandler", ""
				Case "OnErrorGotoResumeNext":   tb->SetErrorHandling "On Error Goto ErrorHandler", "Resume Next"
				Case "RemoveErrorHandling":     tb->RemoveErrorHandling
				End Select
			End If
		End If
	Case "Options":                         pfOptions->Show *pfrmMain
	Case "AddIns":                          pfAddIns->Show *pfrmMain
	Case "Tools":                           pfTools->Show *pfrmMain
	Case "Content":                         ThreadCounter(ThreadCreate_(@RunHelp))
	Case "FreeBasicForums":                 OpenUrl "https://www.freebasic.net/forum/index.php"
	Case "FreeBasicWiKi":                   OpenUrl "https://www.freebasic.net/wiki/wikka.php?wakka=PageIndex"
	Case "GitHubWebSite":                   OpenUrl "https://github.com"
	Case "FreeBasicRepository":             OpenUrl "https://github.com/freebasic/fbc"
	Case "VisualFBEditorRepository":        OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor"
	Case "VisualFBEditorWiKi":              OpenUrl "https://github.com/XusinboyBekchanov/VisualFBEditor/wiki"
	Case "MyFbFrameworkRepository":         OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework"
	Case "MyFbFrameworkWiKi":               OpenUrl "https://github.com/XusinboyBekchanov/MyFbFramework/wiki"
	Case "About":                            pfAbout->Show *pfrmMain
	Case "TipoftheDay":                      pfTipOfDay->ShowModal *pfrmMain
	End Select
End Sub

pApp->MainForm = @frmMain
pApp->Run

End
AA:
MsgBox ErrDescription(Err) & " (" & Err & ") " & _
"in function " & ZGet(Erfn()) & " " & _
"in module " & ZGet(Ermn()) ' & " " & _
'"in line " & Erl()
 
