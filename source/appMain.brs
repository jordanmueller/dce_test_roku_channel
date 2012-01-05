' ********************************************************************
' **  Sample PlayVideo App
' **  Copyright (c) 2009 Roku Inc. All Rights Reserved.
' ********************************************************************

Sub Main(args As Dynamic)
    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    if type(args) = "roAssociativeArray" and type(args.url) = "roString" then
        displayVideo(args)
    end if
    print "Type args = "; type(args)
    print "Type args.url = "; type(args.url)

    'has to live for the duration of the whole app to prevent flashing
    'back to the roku home screen.
    screenFacade = CreateObject("roPosterScreen")
    screenFacade.show()

    itemMpeg4 = {   ContentType:"episode"
               SDPosterUrl:"file://pkg:/images/PaulFarmer.jpg"
               HDPosterUrl:"file://pkg:/images/PaulFarmer.jpg"
               IsHD:False
               HDBranded:False
               ShortDescriptionLine1:"Paul Farmer: Case Studies in Global Health: Biosocial Perspectives"
               ShortDescriptionLine2:""
               Description:"Paul Farmer: Case Studies in Global Health: Biosocial Perspectives"
               Rating:"NR"
               StarRating:"80"
               Length:1280
               Categories:["Global Health","Talk"]
               Title:"Paul Farmer"
               }


   showSpringboardScreen(itemMpeg4) 
    
    'exit the app gently so that the screen doesn't flash to black
    screenFacade.showMessage("")
    sleep(25)
End Sub

'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangPrimaryLogoOffsetSD_X = "72"
    theme.OverhangPrimaryLogoOffsetSD_Y = "15"
    theme.OverhangSliceSD = "pkg:/images/Overhang_BackgroundSlice_SD43.png"
    theme.OverhangPrimaryLogoSD  = "pkg:/images/Logo_Overhang_SD43.png"

    theme.OverhangPrimaryLogoOffsetHD_X = "123"
    theme.OverhangPrimaryLogoOffsetHD_Y = "20"
    theme.OverhangSliceHD = "pkg:/images/Overhang_BackgroundSlice_HD.png"
    theme.OverhangPrimaryLogoHD  = "pkg:/images/Logo_Overhang_HD.png"
    
    app.SetTheme(theme)

End Sub


'*************************************************************
'** showSpringboardScreen()
'*************************************************************

Function showSpringboardScreen(item as object) As Boolean
    port = CreateObject("roMessagePort")
    screen = CreateObject("roSpringboardScreen")

    print "showSpringboardScreen"
    
    screen.SetMessagePort(port)
    screen.AllowUpdates(false)
    if item <> invalid and type(item) = "roAssociativeArray"
        screen.SetContent(item)
    endif

    screen.SetDescriptionStyle("generic") 'audio, movie, video, generic
                                        ' generic+episode=4x3,
    screen.ClearButtons()
    screen.AddButton(1,"Play")
    screen.AddButton(2,"Go Back")
    screen.SetStaticRatingEnabled(false)
    screen.AllowUpdates(true)
    screen.Show()

    downKey=3
    selectKey=6
    while true
        msg = wait(0, screen.GetMessagePort())
        if type(msg) = "roSpringboardScreenEvent"
            if msg.isScreenClosed()
                print "Screen closed"
                exit while                
            else if msg.isButtonPressed()
                    print "Button pressed: "; msg.GetIndex(); " " msg.GetData()
                    if msg.GetIndex() = 1
                         displayVideo("")
                    else if msg.GetIndex() = 2
                         return true
                    endif
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        else 
            print "wrong type.... type=";msg.GetType(); " msg: "; msg.GetMessage()
        endif
    end while


    return true
End Function


'*************************************************************
'** displayVideo()
'*************************************************************

Function displayVideo(args As Dynamic)
    print "Displaying video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)

    'bitrates  = [0]          ' 0 = no dots, adaptive bitrate
    'bitrates  = [348]    ' <500 Kbps = 1 dot
    'bitrates  = [664]    ' <800 Kbps = 2 dots
    'bitrates  = [996]    ' <1.1Mbps  = 3 dots
    'bitrates  = [2048]    ' >=1.1Mbps = 4 dots
    bitrates  = [0]    

    urls = ["http://podcast.dce.harvard.edu/2012/01/13669/L01/13669-20110901-L01-1-mp4-av1000-16x9.mp4"]
    qualities = ["SD"]
    StreamFormat = "mp4"
    title = "Paul Farmer - Haiti After the Earthquake: A Critical Sociology - hour 1"
    srt = ""

    if type(args) = "roAssociativeArray"
        if type(args.url) = "roString" and args.url <> "" then
            urls[0] = args.url
        end if
        if type(args.StreamFormat) = "roString" and args.StreamFormat <> "" then
            StreamFormat = args.StreamFormat
        end if
        if type(args.title) = "roString" and args.title <> "" then
            title = args.title
        else 
            title = ""
        end if
        if type(args.srt) = "roString" and args.srt <> "" then
            srt = args.StreamFormat
        else 
            srt = ""
        end if
    end if
    
    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = urls
    videoclip.StreamQualities = qualities
    videoclip.StreamFormat = StreamFormat
    videoclip.Title = title
    print "srt = ";srt
    if srt <> invalid and srt <> "" then
        videoclip.SubtitleUrl = srt
    end if
    
    video.SetContent(videoclip)
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 'position must change by more than this number of seconds before saving

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                print "Closing video screen"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        end if
    end while
End Function

