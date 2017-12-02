echo off

fxc.exe /nologo /Fo ..\dll\Shaders\deferredVS20.bin /E std_VS /T vs_2_0 defferedshading.fx
fxc.exe /nologo /Fo ..\dll\Shaders\deferredPS20.bin /E std_PS /T ps_2_0 defferedshading.fx

fxc.exe /nologo /Fo ..\dll\Shaders\deferredVS30.bin /E std_VS /T vs_3_0 defferedshading.fx
fxc.exe /nologo /Fo ..\dll\Shaders\deferredPS30.bin /E std_PS /T ps_3_0 defferedshading.fx

fxc.exe /nologo /Fo ..\dll\Shaders\mrtVS20.bin /E std_VS /T vs_2_0 mrt.fx
fxc.exe /nologo /Fo ..\dll\Shaders\mrtPS20.bin /E std_PS /T ps_2_0 mrt.fx

fxc.exe /nologo /Fo ..\dll\Shaders\mrtVS30.bin /E std_VS /T vs_3_0 mrt.fx
fxc.exe /nologo /Fo ..\dll\Shaders\mrtPS30.bin /E std_PS /T ps_3_0 mrt.fx

fxc.exe /nologo /Fo ..\dll\Shaders\CircleVS20.bin /E std_VS /T vs_2_0 Circle.fx
fxc.exe /nologo /Fo ..\dll\Shaders\CirclePS20.bin /E std_PS /T ps_2_0 Circle.fx

fxc.exe /nologo /Fo ..\dll\Shaders\CircleVS30.bin /E std_VS /T vs_3_0 Circle.fx
fxc.exe /nologo /Fo ..\dll\Shaders\CirclePS30.bin /E std_PS /T ps_3_0 Circle.fx

fxc.exe /nologo /Fo ..\dll\Shaders\BlendAddVS20.bin /E std_VS /T vs_2_0 BlendAdd.fx
fxc.exe /nologo /Fo ..\dll\Shaders\BlendAddPS20.bin /E std_PS /T ps_2_0 BlendAdd.fx

fxc.exe /nologo /Fo ..\dll\Shaders\BlendAddVS30.bin /E std_VS /T vs_3_0 BlendAdd.fx
fxc.exe /nologo /Fo ..\dll\Shaders\BlendAddPS30.bin /E std_PS /T ps_3_0 BlendAdd.fx


pause