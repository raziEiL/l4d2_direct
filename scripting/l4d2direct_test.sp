#include <sourcemod>
#include <l4d2_direct>


/* These class numbers are the same ones used internally in L4D2 */
enum SIClass
{
	SI_None=0,
	SI_Smoker=1,
	SI_Boomer,
	SI_Hunter,
	SI_Spitter,
	SI_Jockey,
	SI_Charger,
	SI_Witch,
	SI_Tank
};

stock const String:g_sSIClassNames[SIClass][] = 
{	"", "Smoker", "Boomer", "Hunter", "Spitter", "Jockey", "Charger", "Witch", "Tank" };


public OnPluginStart()
{
	RegConsoleCmd("sm_addtest", addtest);
	RegConsoleCmd("sm_timertest", timertest);
	RegConsoleCmd("sm_sitimers", sitimers);
	RegConsoleCmd("sm_dumpglobals", dumpglobals);
	RegConsoleCmd("sm_settank", settank);
	RegConsoleCmd("sm_myaddy", myaddy);
	RegConsoleCmd("sm_myspawntimer", myspawntimer);
	RegConsoleCmd("sm_mytickets", mytickets);
	RegConsoleCmd("sm_myflow", myflow);
	RegConsoleCmd("sm_myflowdist", myflowdist);
}

public Action:myflowdist(client, args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "Clients only");
		return;
	}

	new Float:dist = L4D2Direct_GetFlowDistance(client);
	ReplyToCommand(client, "flowdist = %f", dist);
}

public Action:myflow(client, args)
{
	if (client == 0)
	{
		ReplyToCommand(client, "Not the server bro");
		return;
	}
	
	new Float:pos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
	
	new Address:pNavArea = L4D2Direct_GetTerrorNavArea(pos);
	
	if (pNavArea == Address_Null)
	{
		ReplyToCommand(client, "You're no where");
		return;
	}
	
	new Float:flow = L4D2Direct_GetTerrorNavAreaFlow(pNavArea);
	new prcnt = RoundToNearest((flow / L4D2Direct_GetMapMaxFlowDistance()) * 100.0);
	ReplyToCommand(client, "flow = %f (%d%%)", flow, prcnt);
}

public Action:mytickets(client, args)
{
	new tickets = L4D2Direct_GetTankTickets(client);
	ReplyToCommand(client, "Your tank lottery tickets = %d", tickets);
}

public Action:myspawntimer(client,args)
{
	new CountdownTimer:spawnTimer = L4D2Direct_GetSpawnTimer(client);
	
	if (spawnTimer != CTimer_Null)
		CTimerReply(client, spawnTimer, "Spawn timer");
	else
		ReplyToCommand(client, "No timer");
	
	return Plugin_Handled;
}

public Action:myaddy(client,args)
{
	if(client == 0)
	{
		ReplyToCommand(client, "Sorry bro gotta be an entity");
		return Plugin_Handled;
	}
	new Address:me = GetEntityAddress(client);
	if(me == Address_Null)
	{
		ReplyToCommand(client, "Utter failure");
		return Plugin_Handled;
	}
	new CountdownTimer:ctimer588 = CountdownTimer:(me+Address:11432);
	new CountdownTimer:ctimer600 = CountdownTimer:(me+Address:11444);
	CTimerReply(client, ctimer588, "ctimer588");
	CTimerReply(client, ctimer600, "ctimer600");

	return Plugin_Handled;
}

public Action:settank(client,args)
{
	static String:buffer[64];
	GetCmdArg(1, buffer, sizeof(buffer));
	new Float:flow = StringToFloat(buffer);
	L4D2Direct_SetVSTankFlowPercent(0, flow);
	L4D2Direct_SetVSTankFlowPercent(1, flow);
	ReplyToCommand(client, "Looks good? %.02f %.02f", L4D2Direct_GetVSTankFlowPercent(0)*100, L4D2Direct_GetVSTankFlowPercent(1)*100);
	return Plugin_Handled;
}

public Action:addtest(client,args)
{
	ReplyToCommand(client, "Tank count: %d", L4D2Direct_GetTankCount());
	ReplyToCommand(client, "Campaign Scores[0]: %d", L4D2Direct_GetVSCampaignScore(0));
	ReplyToCommand(client, "Campaign Scores[1]: %d", L4D2Direct_GetVSCampaignScore(1));
	ReplyToCommand(client, "Map Max flow Distance: %f", L4D2Direct_GetMapMaxFlowDistance());
	ReplyToCommand(client, "Tank spawn[0]: %s %f %f", 
		L4D2Direct_GetVSTankToSpawnThisRound(0) ? "yes" : "no", 
		L4D2Direct_GetVSTankFlowPercent(0), 
		L4D2Direct_GetVSTankFlowPercent(0)*L4D2Direct_GetMapMaxFlowDistance());
	ReplyToCommand(client, "Tank spawn[1]: %s %f %f", 
		L4D2Direct_GetVSTankToSpawnThisRound(1) ? "yes" : "no", 
		L4D2Direct_GetVSTankFlowPercent(1), 
		L4D2Direct_GetVSTankFlowPercent(1)*L4D2Direct_GetMapMaxFlowDistance());
	ReplyToCommand(client, "Witch spawn[0]: %s %f %f", 
		L4D2Direct_GetVSWitchToSpawnThisRound(0) ? "yes" : "no", 
		L4D2Direct_GetVSWitchFlowPercent(0), 
		L4D2Direct_GetVSWitchFlowPercent(0)*L4D2Direct_GetMapMaxFlowDistance());
	ReplyToCommand(client, "Witch spawn[1]: %s %f %f", 
		L4D2Direct_GetVSWitchToSpawnThisRound(1) ? "yes" : "no", 
		L4D2Direct_GetVSWitchFlowPercent(1), 
		L4D2Direct_GetVSWitchFlowPercent(1)*L4D2Direct_GetMapMaxFlowDistance());

	new CountdownTimer:VSStartTimer = L4D2Direct_GetVSStartTimer();
	ReplyToCommand(client, "Saferoom opens in: %fs", CTimer_GetRemainingTime(VSStartTimer));

	return Plugin_Handled;
}

stock CTimerReply(client, CountdownTimer:timer, const String:name[])
{
	if(CTimer_HasStarted(timer))
	{
		ReplyToCommand(client, "%s: yes %.02f %.02f", name, CTimer_GetElapsedTime(timer), CTimer_GetRemainingTime(timer));
	}
	else
	{
		ReplyToCommand(client, "%s: no", name);
	}
}

stock ITimerReply(client, IntervalTimer:timer, const String:name[])
{
	if(ITimer_HasStarted(timer))
	{
		ReplyToCommand(client, "%s: yes %.02f", name, ITimer_GetElapsedTime(timer));
	}
	else
	{
		ReplyToCommand(client, "%s: no", name);
	}
}

public Action:timertest(client,args)
{
	CTimerReply(client, L4D2Direct_GetMobSpawnTimer(), "MobSpawn");
	CTimerReply(client, L4D2Direct_GetVSStartTimer(), "VersusStart");
	
	CTimerReply(client, L4D2Direct_GetScavengeRoundSetupTimer(), "ScavRoundStart");
	CTimerReply(client, L4D2Direct_GetScavengeOvertimeGraceTimer(), "ScavOvertime");
	return Plugin_Handled;
}

public Action:sitimers(client, args)
{
	ReplyToCommand(client, "SI Death Timers:");
	for(new i = _:SI_Smoker; i <= _:SI_Charger; i++)
	{
		ITimerReply(client, L4D2Direct_GetSIClassDeathTimer(i), g_sSIClassNames[SIClass:i]);
	}
	ReplyToCommand(client, "SI Spawn Timers:");
	for(new i = _:SI_Smoker; i <= _:SI_Charger; i++)
	{
		CTimerReply(client, L4D2Direct_GetSIClassSpawnTimer(i), g_sSIClassNames[SIClass:i]);
	}
	
	return Plugin_Handled;
}

public Action:dumpglobals(client, args)
{
	decl String:fnameBuf[64];
	new Handle:curfile;
	new len;
	
	Format(fnameBuf, sizeof(fnameBuf), "CDirector_%d.bin", GetTime());
	curfile = OpenFile(fnameBuf, "wb");
	len = GameConfGetOffset(L4D2Direct_GetGameConf(), "sizeof_CDirector");
	DumpGlobalToFile(L4D2Direct_GetCDirector(), len, curfile);
	CloseHandle(curfile);

	Format(fnameBuf, sizeof(fnameBuf), "CDirectorVersusMode_%d.bin", GetTime());
	curfile = OpenFile(fnameBuf, "wb");
	len = GameConfGetOffset(L4D2Direct_GetGameConf(), "sizeof_CDirectorVersusMode");
	DumpGlobalToFile(L4D2Direct_GetCDirectorVersusMode(), len, curfile);
	CloseHandle(curfile);	

	Format(fnameBuf, sizeof(fnameBuf), "CDirectorScavengeMode_%d.bin", GetTime());
	curfile = OpenFile(fnameBuf, "wb");
	len = GameConfGetOffset(L4D2Direct_GetGameConf(), "sizeof_CDirectorScavengeMode");
	DumpGlobalToFile(L4D2Direct_GetCDirectorScavengeMode(), len, curfile);
	CloseHandle(curfile);

	Format(fnameBuf, sizeof(fnameBuf), "TerrorNavMesh_%d.bin", GetTime());
	curfile = OpenFile(fnameBuf, "wb");
	len = GameConfGetOffset(L4D2Direct_GetGameConf(), "sizeof_TerrorNavMesh");
	DumpGlobalToFile(L4D2Direct_GetTerrorNavMesh(), len, curfile);
	CloseHandle(curfile);

	return Plugin_Handled;
}

stock bool:DumpGlobalToFile(Address:pGlobal, size, Handle:file)
{
	new buffer[size];
	DumpGlobal(pGlobal, buffer, size);
	return WriteFile(file, buffer, size, 1);
}

stock DumpGlobal(Address:pGlobal, buffer[], size)
{
	new Address:pEnd = pGlobal + Address:size;
	new Address:pCur = pGlobal;
	new loc=0;
	while(pCur < pEnd)
	{
		buffer[loc++] = LoadFromAddress(pCur++, NumberType_Int8);
	}
}