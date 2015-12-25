
#include "..\..\..\headers\quadengine.h"
#include "..\..\..\headers\Vec2f.h"

IQuadDevice* quadDevice;
IQuadRender* quadRender;
IQuadWindow* quadWindow;
IQuadTimer* quadTimer;
IQuadInput* quadInput;

void __stdcall onTimer(double& delta, unsigned int id)
{

	quadRender->BeginRender();
	quadRender->Clear(0xFF00FF00);

	
	quadRender->EndRender();
}

void main()
{
	CreateQuadDevice(quadDevice);

	quadDevice->CreateWindowEx(quadWindow);
	quadWindow->SetSize(800, 600);
	quadWindow->SetPosition(600, 10);

	//quadWindow->SetOnMouseMove((TOnMouseMoveEvent)onMouseMoveEvent);

	quadWindow->CreateInput(quadInput);

	quadWindow->SetCaption(L"Demo 03 - Window");
	quadDevice->CreateRender(quadRender);

	quadRender->Initialize(quadWindow->GetHandle(), 800, 600, false);

	//quadDevice->CreateAndLoadTexture(0, L"Data\\quadlogo.png", texLogo);

	//quadDevice->CreateTimerEx(quadTimer, (QuadTimerProcedure)onTimer, 16, true);

	quadDevice->CreateTimer(quadTimer);
	quadTimer->SetInterval(16);
	quadTimer->SetCallBack((TTimerProcedure)onTimer);
	quadTimer->SetState(true);

	quadWindow->Start();
	return;
}