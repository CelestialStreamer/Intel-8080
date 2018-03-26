#include"State8080.h"
#include <iostream>
#include <iomanip>
#include <bitset>

uint8_t parity(uint8_t v)
{
   // From manual Parity Bit
   // "The Parity bit is set to 1 for even parity, and is reset to 0 for odd parity."
   if (std::bitset<8>(v).count() % 2 == 0) // If even parity
      return EVEN;
   else
      return ODD;
}

char* functionName(int address)
{
   switch (address)
   {
      // Startup and Interrupts
   case 0x0000: return "Reset";
   case 0x0008: return "ScanLine96";
   case 0x0010: return "ScanLine224";
      // The Aliens
   case 0x00B1: return "InitRack";
   case 0x0100: return "DrawAlien";
   case 0x0141: return "CursorNextAlien";
   case 0x017A: return "GetAlienCoords";
   case 0x01A1: return "MoveRefAlien";
   case 0x01C0: return "InitAliens";
   case 0x01CD: return "ReturnTwo";
      // Misc
   case 0x01CF: return "DrawBottomLine";
   case 0x01D9: return "AddDelta";
   case 0x01E4: return "CopyRAMMirror";
      // Copy/Restore Shields
   case 0x01EF: return "DrawShielPl1";
   case 0x01F5: return "DrawShielPl2";
   case 0x0209: return "RememberShields1";
   case 0x021A: return "RememberShields2";
   case 0x021E: return "CopyShields";
      // Game Objects
   case 0x0248: return "RunGameObjs";

   case 0x028E: return "GameObj0";

   case 0x03BB: return "GameObj1";
   case 0x03FA: return "InitPlyShot";
   case 0x040A: return "MovePlyShot";
   case 0x0430: return "ReadPlyShot";
   case 0x0436: return "EndOfBlowup";

   case 0x0476: return "GameObj2";
   case 0x04AB: return "ResetShot";

   case 0x04B6: return "GameObj3";
   case 0x0550: return "ToShotStruct";
   case 0x055B: return "FromShotStruct";
   case 0x0563: return "HandleAlienShot";
   case 0x062F: return "FindInColumn";
   case 0x0644: return "ShotBlowingUp";

   case 0x0682: return "GameObj4";
   case 0x0765: return "WaitForStart";
   case 0x0798: return "NewGame";
   case 0x0886: return "GetAlRefPtr";
   case 0x088D: return "PromptPlayer";
   case 0x08D1: return "GetShipsPerCred";
   case 0x08D8: return "SpeedShots";
   case 0x08F3: return "PrintMessage";
   case 0x08FF: return "DrawChar";
   case 0x0913: return "TimeToSaucer";
   case 0x097C: return "AlienScoreValue";
   case 0x0988: return "AdjustScore";
   case 0x09AD: return "Print4Digits";
   case 0x09B2: return "DrawHexByte";
   case 0x09D6: return "ClearPlayField";
   case 0x0A5F: return "ScoreForAlien";
   case 0x0A80: return "Animate";
   case 0x0A93: return "PrintMessageDel";
   case 0x0AAB: return "SplashSquiggly";
   case 0x0AB1: return "OneSecDelay";
   case 0x0AB6: return "TwoSecDelay";
   case 0x0ABB: return "SplashDemo";
   case 0x0ABF: return "ISRSplTasks";
   case 0x0AD7: return "WaitOnDelay";
   case 0x0AE2: return "IniSplashAni";
   case 0x1400: return "DrawShiftedSprite";
   case 0x1424: return "EraseSimpleSprite";
   case 0x1439: return "DrawSimpSprite";
   case 0x1452: return "EraseShifted";
   case 0x1474: return "CnvtPixNumber";
   case 0x147C: return "RememberShields";
   case 0x1491: return "DrawSprCollision";
   case 0x14CB: return "ClearSmallSprite";
   case 0x14D8: return "PlayerShotHit";
   case 0x1504: return "CodeBug1";
   case 0x1538: return "AExplodeTime";
   case 0x1554: return "Cnt16s";
   case 0x1562: return "FindRow";
   case 0x156F: return "FindColumn";
   case 0x1581: return "GetAlienStatPtr";
   case 0x1590: return "WrapRef";
   case 0x1597: return "RackBump";
   case 0x15D3: return "DrawSprite";
   case 0x15F3: return "CountAliens";
   case 0x1611: return "GetPlayerDataPtr";
   case 0x1618: return "PlrFireOrDemo";
   case 0x170E: return "AShotReloadRate";
   case 0x172C: return "ShotSound";
   case 0x1740: return "TimeFleetSound";
   case 0x1775: return "FleetDelayExShip";
   case 0x17B4: return "SndOffExtPly";
   case 0x17C0: return "ReadInput";
   case 0x17CD: return "CheckHandleTilt";
   case 0x1804: return "CtrlSaucerSound";
   case 0x1815: return "DrawAdvTable";
   case 0x1856: return "ReadPriStruct";
   case 0x1868: return "SplashSprite";
   case 0x18FA: return "SoundBits3On";
   case 0x1904: return "InitAliensP2";
   case 0x190A: return "PlyrShotAndBump";
   case 0x1910: return "CurPlyAlive";
   case 0x191A: return "DrawScoreHead";
   case 0x1931: return "DrawScore";
   case 0x1947: return "DrawNumCredits";
   case 0x1950: return "PrintHiScore";
   case 0x1956: return "DrawStatus";
   case 0x199A: return "CheckHiddenMes";
   case 0x19BE: return "MessageTaito";
   case 0x19D1: return "EnableGameTasks";
   case 0x19D7: return "DsableGameTasks";
   case 0x19DC: return "SoundBits3Off";
   case 0x19E6: return "DrawNumShips";
   case 0x1A06: return "CompYToBeam";
   case 0x1A32: return "BlockCopy";
   case 0x1A3B: return "ReadDesc";
   case 0x1A47: return "ConvToScr";
   case 0x1A5C: return "ClearScreen";
   case 0x1A69: return "RestoreShields";
   case 0x1A7F: return "RemoveShip";
   default:
      char* buffer = new char[50];
      sprintf(buffer, "$%04x", address);
      return buffer;
   }
}

char* variableName(int address)
{
   switch (address)
   {
   case 0x2000: return "waitOnDraw";
   case 0x2002: return "alienIsExploding";
   case 0x2003: return "expAlienTimer";
   case 0x2004: return "alienRow";
   case 0x2005: return "alienFrame";
   case 0x2006: return "alienCurIndex";
   case 0x2007: return "refAlienDYr";
   case 0x2008: return "refAlienDXr";
   case 0x2009: return "refAlienYr";
   case 0x200A: return "refAlienXr";
   case 0x200B: return "alienPosLSB";
   case 0x200C: return "alienPosMSB";
   case 0x200D: return "rackDirection";
   case 0x200E: return "rackDownDelta";
      // GameObject0
   case 0x2010: return "obj0TimerMSB";
   case 0x2011: return "obj0TimerLSB";
   case 0x2012: return "obj0TimerExtra";
   case 0x2013: return "obj0HanlderLSB";
   case 0x2014: return "oBJ0HanlderMSB";
   case 0x2015: return "playerAlive";
   case 0x2016: return "expAnimateTimer";
   case 0x2017: return "expAnimateCnt";
   case 0x2018: return "plyrSprPicL";
   case 0x2019: return "plyrSprPicM";
   case 0x201A: return "playerYr";
   case 0x201B: return "playerXr";
   case 0x201C: return "plyrSprSiz";
   case 0x201D: return "nextDemoCmd";
   case 0x201E: return "hidMessSeq";
   case 0x2020: return "obj1TimerMSB";

      // GameObject1
   case 0x2021: return "obj1TimerLSB";
   case 0x2022: return "obj1TimerExtra";
   case 0x2023: return "obj1HandlerLSB";
   case 0x2024: return "obj1HandlerMSB";
   case 0x2025: return "plyrShotStatus";
   case 0x2026: return "blowUpTimer";
   case 0x2027: return "obj1ImageLSB";
   case 0x2028: return "obj1ImageMSB";
   case 0x2029: return "obj1CoorYr";
   case 0x202A: return "obj1CoorXr";
   case 0x202B: return "obj1ImageSize";
   case 0x202C: return "shotDeltaX";
   case 0x202D: return "fireBounce";

      // GameObject2
   case 0x2030: return "obj2TimerMSB";
   case 0x2031: return "obj2TimerLSB";
   case 0x2032: return "obj2TimerExtra";
   case 0x2033: return "obj2HandlerLSB";
   case 0x2034: return "obj2HandlerMSB";
   case 0x2035: return "rolShotStatus";
   case 0x2036: return "rolShotStepCnt";
   case 0x2037: return "rolShotTrack";
   case 0x2038: return "rolShotCFirLSB";
   case 0x2039: return "rolShotCFirMSB";
   case 0x203A: return "rolShotBlowCnt";
   case 0x203B: return "rolShotImageLSB";
   case 0x203C: return "rolShotImageMSB";
   case 0x203D: return "rolShotYr";
   case 0x203E: return "rolShotXr";
   case 0x203F: return "rolShotSize";

      // GameObject3
   case 0x2040: return "obj3TimerMSB";
   case 0x2041: return "obj3TimerLSB";
   case 0x2042: return "obj3TimerExtra";
   case 0x2043: return "obj3HandlerLSB";
   case 0x2044: return "obj3HandlerMSB";
   case 0x2045: return "pluShotStatus";
   case 0x2046: return "pluShotStepCnt";
   case 0x2047: return "pluShotTrack";
   case 0x2048: return "pluShotCFirLSB";
   case 0x2049: return "pluShotCFirMSB";
   case 0x204A: return "pluShotBlowCnt";
   case 0x204B: return "pluShotImageLSB";
   case 0x204C: return "pluShotImageMSB";
   case 0x204D: return "pluShotYr";
   case 0x204E: return "pluSHotXr";
   case 0x204F: return "pluShotSize";

      // GameObject4
   case 0x2050: return "obj4TimerMSB";
   case 0x2051: return "obj4TimerLSB";
   case 0x2052: return "obj4TimerExtra";
   case 0x2053: return "obj4HandlerLSB";
   case 0x2054: return "obj4HandlerMSB";
   case 0x2055: return "squShotStatus";
   case 0x2056: return "squShotStepCnt";
   case 0x2057: return "squShotTrack";
   case 0x2058: return "squShotCFirLSB";
   case 0x2059: return "squShotCFirMSB";
   case 0x205A: return "squSHotBlowCnt";
   case 0x205B: return "squShotImageLSB";
   case 0x205C: return "squShotImageMSB";
   case 0x205D: return "squShotYr";
   case 0x205E: return "squShotXr";
   case 0x205F: return "squShotSize";
   case 0x2060: return "endOfTasks";
   case 0x2061: return "collision";
   case 0x2062: return "expAlienLSB";
   case 0x2063: return "expAlienMSB";
   case 0x2064: return "expAlienYr";
   case 0x2065: return "expAlienXr";
   case 0x2066: return "expAlienSize";
   case 0x2067: return "playerDataMSB";
   case 0x2068: return "playerOK";
   case 0x2069: return "enableAlienFire";
   case 0x206A: return "alienFireDelay";
   case 0x206B: return "oneAlien";
   case 0x206C: return "temp206C";
   case 0x206D: return "invaded";
   case 0x206E: return "skipPlunger";
   case 0x2070: return "otherShot1";
   case 0x2071: return "otherShot2";
   case 0x2072: return "vblankStatus";

      // Alien shot information
   case 0x2073: return "aShotStatus";
   case 0x2074: return "aShotStepCnt";
   case 0x2075: return "aShotTrack";
   case 0x2076: return "aShotCFirLSB";
   case 0x2077: return "aShotCFirMSB";
   case 0x2078: return "aShotBlowCnt";
   case 0x2079: return "aShotImageLSB";
   case 0x207A: return "aShotImageMSB";
   case 0x207B: return "alienShotYr";
   case 0x207C: return "alienShotXr";
   case 0x207D: return "alienShotSize";
   case 0x207E: return "alienShotDelta";
   case 0x207F: return "shotPicEnd";
   case 0x2080: return "shotSync";
   case 0x2081: return "tmp2081";
   case 0x2082: return "numAliens";
   case 0x2083: return "saucerStart";
   case 0x2084: return "saucerActive";
   case 0x2085: return "saucerHit";
   case 0x2086: return "saucerHitTime";
   case 0x2087: return "saucerPriLocLSB";
   case 0x2088: return "saucerPriLocMSB";
   case 0x2089: return "saucerPriPicLSB";
   case 0x208A: return "saucerPriPicMSB";
   case 0x208B: return "saucerPriSize";
   case 0x208C: return "saucerDeltaY";
   case 0x208D: return "sauScoreLSB";
   case 0x208E: return "sauScoreMSB";
   case 0x208F: return "shotCountLSB";
   case 0x2090: return "shotCountMSB";
   case 0x2091: return "tillSaucerLSB";
   case 0x2092: return "tillSaucerMSB";
   case 0x2093: return "waitStartLoop";
   case 0x2094: return "soundPort3";
   case 0x2095: return "changeFleetSnd";
   case 0x2096: return "fleetSndCnt";
   case 0x2097: return "fleetSndReload";
   case 0x2098: return "soundPort5";
   case 0x2099: return "extraHold";
   case 0x209A: return "tilt";
   case 0x209B: return "fleetSndHold";

      // Splash screen animation structure
   case 0x20C0: return "isrDelay";
   case 0x20C1: return "isrSplashTask";
   case 0x20C2: return "splashAnForm";
   case 0x20C3: return "splashDeltaX";
   case 0x20C4: return "splashDeltaY";
   case 0x20C5: return "splashYr";
   case 0x20C6: return "splashXr";
   case 0x20C7: return "splashImageLSB";
   case 0x20C8: return "splashImageMSB";
   case 0x20C9: return "splashImageSize";
   case 0x20CA: return "splashTargetY";
   case 0x20CB: return "splashReached";
   case 0x20CC: return "splashImRestLSB";
   case 0x20CD: return "splashImRestMSB";
   case 0x20CE: return "twoPlayers";
   case 0x20CF: return "aShotReloadRate";
   case 0x20E5: return "player1Ex";
   case 0x20E6: return "player2Ex";
   case 0x20E7: return "player1Alive";
   case 0x20E8: return "player2Alive";
   case 0x20E9: return "suspendPlay";
   case 0x20EA: return "coinSwitch";
   case 0x20EB: return "numCoins";
   case 0x20EC: return "splashAnimate";
   case 0x20ED: return "demoCmdPtrLSB";
   case 0x20EE: return "demoCmdPtrMSB";
   case 0x20EF: return "gameMode";
   case 0x20F1: return "adjustScore";
   case 0x20F2: return "scoreDeltaLSB";
   case 0x20F3: return "scoreDeltaMSB";
   case 0x20F4: return "HiScorL";
   case 0x20F5: return "HiScorM";
   case 0x20F6: return "HiScorLoL";
   case 0x20F7: return "HiScorLoM";
   case 0x20F8: return "P1ScorL";
   case 0x20F9: return "P1ScorM";
   case 0x20FA: return "P1ScorLoL";
   case 0x20FB: return "P1ScorLoM";
   case 0x20FC: return "P2ScorL";
   case 0x20FD: return "P2ScorM";
   case 0x20FE: return "P2ScorLoL";
   case 0x20FF: return "P2ScorLoM";

      // Player 1 specific data
   case 0x21FB: return "p1RefAlienDX";
   case 0x21FC: return "p1RefAlienY";
   case 0x21FD: return "p1RefAlienX";
   case 0x21FE: return "p1RackCnt";
   case 0x21FF: return "p1ShipsRem";

      // Player 2 specific data
   case 0x22FB: return "p2RefAlienDX";
   case 0x22FC: return "p2RefAlienYr";
   case 0x22FD: return "p2RefAlienXr";
   case 0x22FE: return "p2RackCnt";
   case 0x22FF: return "p2ShipsRem";

   default:
      char* buffer = new char[50];
      sprintf(buffer, "$%04x", address);
      return buffer;
   }
}

int State8080::Disassemble8080Op()
{
   //unsigned char *code = &memory->read(Reg.pc);
   unsigned char *code = &memory->memory[Reg.pc];
   unsigned char value = code[1];
   unsigned int address = code[2] << 8 | code[1];

   int opbytes = 1;
   printf("%04x ", Reg.pc);
   switch (*code)
   {
   case 0x01: opbytes = 3; break;
   case 0x06: opbytes = 2; break;
   case 0x0e: opbytes = 2; break;
   case 0x11: opbytes = 3; break;
   case 0x16: opbytes = 2; break;
   case 0x1e: opbytes = 2; break;
   case 0x21: opbytes = 3; break;
   case 0x22: opbytes = 3; break;
   case 0x26: opbytes = 2; break;
   case 0x2a: opbytes = 3; break;
   case 0x2e: opbytes = 2; break;
   case 0x31: opbytes = 3; break;
   case 0x32: opbytes = 3; break;
   case 0x36: opbytes = 2; break;
   case 0x3a: opbytes = 3; break;
   case 0x3e: opbytes = 2; break;
   case 0xc2: opbytes = 3; break;
   case 0xc3: opbytes = 3; break;
   case 0xc4: opbytes = 3; break;
   case 0xc6: opbytes = 2; break;
   case 0xca: opbytes = 3; break;
   case 0xcb: opbytes = 3; break;
   case 0xcc: opbytes = 3; break;
   case 0xcd: opbytes = 3; break;
   case 0xce: opbytes = 2; break;
   case 0xd2: opbytes = 3; break;
   case 0xd3: opbytes = 2; break;
   case 0xd4: opbytes = 3; break;
   case 0xd6: opbytes = 2; break;
   case 0xda: opbytes = 3; break;
   case 0xdb: opbytes = 2; break;
   case 0xdc: opbytes = 3; break;
   case 0xdd: opbytes = 3; break;
   case 0xde: opbytes = 2; break;
   case 0xe2: opbytes = 3; break;
   case 0xe4: opbytes = 3; break;
   case 0xe6: opbytes = 2; break;
   case 0xea: opbytes = 3; break;
   case 0xec: opbytes = 3; break;
   case 0xed: opbytes = 3; break;
   case 0xee: opbytes = 2; break;
   case 0xf2: opbytes = 3; break;
   case 0xf4: opbytes = 3; break;
   case 0xf6: opbytes = 2; break;
   case 0xfa: opbytes = 3; break;
   case 0xfc: opbytes = 3; break;
   case 0xfd: opbytes = 3; break;
   case 0xfe: opbytes = 2; break;
   }
   if (opbytes == 1)
      printf("%02x       ", code[0]);
   else if (opbytes == 2)
      printf("%02x %02x    ", code[0], code[1]);
   else
      printf("%02x %02x %02x ", code[0], code[1], code[2]);

   char mnemonic[50];

   switch (*code)
   {
   case 0x00: sprintf(mnemonic, "NOP"); break;
   case 0x01: sprintf(mnemonic, "LD     BC,%s", variableName(address)); opbytes = 3; break;
   case 0x02: sprintf(mnemonic, "LD     (BC),A"); break;
   case 0x03: sprintf(mnemonic, "INC    BC"); break;
   case 0x04: sprintf(mnemonic, "INC    B"); break;
   case 0x05: sprintf(mnemonic, "DEC    B"); break;
   case 0x06: sprintf(mnemonic, "LD     B,$%02x", value); opbytes = 2; break;
   case 0x07: sprintf(mnemonic, "RLCA"); break;
   case 0x08: sprintf(mnemonic, "NOP"); break; // unused
   case 0x09: sprintf(mnemonic, "ADD    HL,BC"); break;
   case 0x0a: sprintf(mnemonic, "LD     A,(BC)"); break;
   case 0x0b: sprintf(mnemonic, "DEC    BC"); break;
   case 0x0c: sprintf(mnemonic, "INC    C"); break;
   case 0x0d: sprintf(mnemonic, "DEC    C"); break;
   case 0x0e: sprintf(mnemonic, "LD     C,$%02x", value); opbytes = 2;	break;
   case 0x0f: sprintf(mnemonic, "RRCA"); break;

   case 0x10: sprintf(mnemonic, "NOP"); break; // unused
   case 0x11: sprintf(mnemonic, "LD     DE,%s", variableName(address)); opbytes = 3; break;
   case 0x12: sprintf(mnemonic, "LD     (DE),A"); break;
   case 0x13: sprintf(mnemonic, "INC    DE"); break;
   case 0x14: sprintf(mnemonic, "INC    D"); break;
   case 0x15: sprintf(mnemonic, "DEC    D"); break;
   case 0x16: sprintf(mnemonic, "LD     D,$%02x", value); opbytes = 2; break;
   case 0x17: sprintf(mnemonic, "RLA"); break;
   case 0x18: sprintf(mnemonic, "NOP"); break; // unused
   case 0x19: sprintf(mnemonic, "ADD    HL,DE"); break;
   case 0x1a: sprintf(mnemonic, "LD     A,(DE)"); break;
   case 0x1b: sprintf(mnemonic, "DEC    DE"); break;
   case 0x1c: sprintf(mnemonic, "INC    E"); break;
   case 0x1d: sprintf(mnemonic, "DEC    E"); break;
   case 0x1e: sprintf(mnemonic, "LD     E,$%02x", value); opbytes = 2; break;
   case 0x1f: sprintf(mnemonic, "RRA"); break;

   case 0x20: sprintf(mnemonic, "NOP"); break; // unused
   case 0x21: sprintf(mnemonic, "LD     HL,%s", variableName(address)); opbytes = 3; break;
   case 0x22: sprintf(mnemonic, "LD     (%s),HL", variableName(address)); opbytes = 3; break;
   case 0x23: sprintf(mnemonic, "INC    HL"); break;
   case 0x24: sprintf(mnemonic, "INC    H"); break;
   case 0x25: sprintf(mnemonic, "DEC    H"); break;
   case 0x26: sprintf(mnemonic, "LD     H,$%02x", value); opbytes = 2; break;
   case 0x27: sprintf(mnemonic, "DAA"); break;
   case 0x28: sprintf(mnemonic, "NOP"); break; // unused
   case 0x29: sprintf(mnemonic, "ADD    HL,HL"); break;
   case 0x2a: sprintf(mnemonic, "LD     HL,(%s)", variableName(address)); opbytes = 3; break;
   case 0x2b: sprintf(mnemonic, "DEC    HL"); break;
   case 0x2c: sprintf(mnemonic, "INC    L"); break;
   case 0x2d: sprintf(mnemonic, "DEC    L"); break;
   case 0x2e: sprintf(mnemonic, "LD     L,$%02x", value); opbytes = 2; break;
   case 0x2f: sprintf(mnemonic, "CMA"); break;

   case 0x30: sprintf(mnemonic, "NOP"); break; // unused
   case 0x31: sprintf(mnemonic, "LD     SP,%s", variableName(address)); opbytes = 3; break;
   case 0x32: sprintf(mnemonic, "LD     (%s),A", variableName(address)); opbytes = 3; break;
   case 0x33: sprintf(mnemonic, "INC    SP"); break;
   case 0x34: sprintf(mnemonic, "INC    (HL)"); break;
   case 0x35: sprintf(mnemonic, "DEC    (HL)"); break;
   case 0x36: sprintf(mnemonic, "LD     (HL),$%02x", value); opbytes = 2; break;
   case 0x37: sprintf(mnemonic, "STC"); break;
   case 0x38: sprintf(mnemonic, "NOP"); break; // unused
   case 0x39: sprintf(mnemonic, "ADD    HL,SP"); break;
   case 0x3a: sprintf(mnemonic, "LD     A,(%s)", variableName(address)); opbytes = 3; break;
   case 0x3b: sprintf(mnemonic, "DEC    SP"); break;
   case 0x3c: sprintf(mnemonic, "INC    A"); break;
   case 0x3d: sprintf(mnemonic, "DEC    A"); break;
   case 0x3e: sprintf(mnemonic, "LD     A,$%02x", value); opbytes = 2; break;
   case 0x3f: sprintf(mnemonic, "CMC"); break;

   case 0x40: sprintf(mnemonic, "LD     B,B"); break;
   case 0x41: sprintf(mnemonic, "LD     B,C"); break;
   case 0x42: sprintf(mnemonic, "LD     B,D"); break;
   case 0x43: sprintf(mnemonic, "LD     B,E"); break;
   case 0x44: sprintf(mnemonic, "LD     B,H"); break;
   case 0x45: sprintf(mnemonic, "LD     B,L"); break;
   case 0x46: sprintf(mnemonic, "LD     B,(HL)"); break;
   case 0x47: sprintf(mnemonic, "LD     B,A"); break;
   case 0x48: sprintf(mnemonic, "LD     C,B"); break;
   case 0x49: sprintf(mnemonic, "LD     C,C"); break;
   case 0x4a: sprintf(mnemonic, "LD     C,D"); break;
   case 0x4b: sprintf(mnemonic, "LD     C,E"); break;
   case 0x4c: sprintf(mnemonic, "LD     C,H"); break;
   case 0x4d: sprintf(mnemonic, "LD     C,L"); break;
   case 0x4e: sprintf(mnemonic, "LD     C,(HL)"); break;
   case 0x4f: sprintf(mnemonic, "LD     C,A"); break;

   case 0x50: sprintf(mnemonic, "LD     D,B"); break;
   case 0x51: sprintf(mnemonic, "LD     D,C"); break;
   case 0x52: sprintf(mnemonic, "LD     D,D"); break;
   case 0x53: sprintf(mnemonic, "LD     D,E"); break;
   case 0x54: sprintf(mnemonic, "LD     D,H"); break;
   case 0x55: sprintf(mnemonic, "LD     D,L"); break;
   case 0x56: sprintf(mnemonic, "LD     D,(HL)"); break;
   case 0x57: sprintf(mnemonic, "LD     D,A"); break;
   case 0x58: sprintf(mnemonic, "LD     E,B"); break;
   case 0x59: sprintf(mnemonic, "LD     E,C"); break;
   case 0x5a: sprintf(mnemonic, "LD     E,D"); break;
   case 0x5b: sprintf(mnemonic, "LD     E,E"); break;
   case 0x5c: sprintf(mnemonic, "LD     E,H"); break;
   case 0x5d: sprintf(mnemonic, "LD     E,L"); break;
   case 0x5e: sprintf(mnemonic, "LD     E,(HL)"); break;
   case 0x5f: sprintf(mnemonic, "LD     E,A"); break;

   case 0x60: sprintf(mnemonic, "LD     H,B"); break;
   case 0x61: sprintf(mnemonic, "LD     H,C"); break;
   case 0x62: sprintf(mnemonic, "LD     H,D"); break;
   case 0x63: sprintf(mnemonic, "LD     H,E"); break;
   case 0x64: sprintf(mnemonic, "LD     H,H"); break;
   case 0x65: sprintf(mnemonic, "LD     H,L"); break;
   case 0x66: sprintf(mnemonic, "LD     H,(HL)"); break;
   case 0x67: sprintf(mnemonic, "LD     H,A"); break;
   case 0x68: sprintf(mnemonic, "LD     L,B"); break;
   case 0x69: sprintf(mnemonic, "LD     L,C"); break;
   case 0x6a: sprintf(mnemonic, "LD     L,D"); break;
   case 0x6b: sprintf(mnemonic, "LD     L,E"); break;
   case 0x6c: sprintf(mnemonic, "LD     L,H"); break;
   case 0x6d: sprintf(mnemonic, "LD     L,L"); break;
   case 0x6e: sprintf(mnemonic, "LD     L,(HL)"); break;
   case 0x6f: sprintf(mnemonic, "LD     L,A"); break;

   case 0x70: sprintf(mnemonic, "LD     (HL),B"); break;
   case 0x71: sprintf(mnemonic, "LD     (HL),C"); break;
   case 0x72: sprintf(mnemonic, "LD     (HL),D"); break;
   case 0x73: sprintf(mnemonic, "LD     (HL),E"); break;
   case 0x74: sprintf(mnemonic, "LD     (HL),H"); break;
   case 0x75: sprintf(mnemonic, "LD     (HL),L"); break;
   case 0x76: sprintf(mnemonic, "HLT"); break;
   case 0x77: sprintf(mnemonic, "LD     (HL),A"); break;
   case 0x78: sprintf(mnemonic, "LD     A,B"); break;
   case 0x79: sprintf(mnemonic, "LD     A,C"); break;
   case 0x7a: sprintf(mnemonic, "LD     A,D"); break;
   case 0x7b: sprintf(mnemonic, "LD     A,E"); break;
   case 0x7c: sprintf(mnemonic, "LD     A,H"); break;
   case 0x7d: sprintf(mnemonic, "LD     A,L"); break;
   case 0x7e: sprintf(mnemonic, "LD     A,(HL)"); break;
   case 0x7f: sprintf(mnemonic, "LD     A,A"); break;

   case 0x80: sprintf(mnemonic, "ADD    A,B"); break;
   case 0x81: sprintf(mnemonic, "ADD    A,C"); break;
   case 0x82: sprintf(mnemonic, "ADD    A,D"); break;
   case 0x83: sprintf(mnemonic, "ADD    A,E"); break;
   case 0x84: sprintf(mnemonic, "ADD    A,H"); break;
   case 0x85: sprintf(mnemonic, "ADD    A,L"); break;
   case 0x86: sprintf(mnemonic, "ADD    A,(HL)"); break;
   case 0x87: sprintf(mnemonic, "ADD    A,A"); break;
   case 0x88: sprintf(mnemonic, "ADC    A,B"); break;
   case 0x89: sprintf(mnemonic, "ADC    A,C"); break;
   case 0x8a: sprintf(mnemonic, "ADC    A,D"); break;
   case 0x8b: sprintf(mnemonic, "ADC    A,E"); break;
   case 0x8c: sprintf(mnemonic, "ADC    A,H"); break;
   case 0x8d: sprintf(mnemonic, "ADC    A,L"); break;
   case 0x8e: sprintf(mnemonic, "ADC    A,(HL)"); break;
   case 0x8f: sprintf(mnemonic, "ADC    A,A"); break;

   case 0x90: sprintf(mnemonic, "SUB    A,B"); break;
   case 0x91: sprintf(mnemonic, "SUB    A,C"); break;
   case 0x92: sprintf(mnemonic, "SUB    A,D"); break;
   case 0x93: sprintf(mnemonic, "SUB    A,E"); break;
   case 0x94: sprintf(mnemonic, "SUB    A,H"); break;
   case 0x95: sprintf(mnemonic, "SUB    A,L"); break;
   case 0x96: sprintf(mnemonic, "SUB    A,(HL)"); break;
   case 0x97: sprintf(mnemonic, "SUB    A,A"); break;
   case 0x98: sprintf(mnemonic, "SBB    A,B"); break;
   case 0x99: sprintf(mnemonic, "SBB    A,C"); break;
   case 0x9a: sprintf(mnemonic, "SBB    A,D"); break;
   case 0x9b: sprintf(mnemonic, "SBB    A,E"); break;
   case 0x9c: sprintf(mnemonic, "SBB    A,H"); break;
   case 0x9d: sprintf(mnemonic, "SBB    A,L"); break;
   case 0x9e: sprintf(mnemonic, "SBB    A,(HL)"); break;
   case 0x9f: sprintf(mnemonic, "SBB    A,A"); break;

   case 0xa0: sprintf(mnemonic, "AND    A,B"); break;
   case 0xa1: sprintf(mnemonic, "AND    A,C"); break;
   case 0xa2: sprintf(mnemonic, "AND    A,D"); break;
   case 0xa3: sprintf(mnemonic, "AND    A,E"); break;
   case 0xa4: sprintf(mnemonic, "AND    A,H"); break;
   case 0xa5: sprintf(mnemonic, "AND    A,L"); break;
   case 0xa6: sprintf(mnemonic, "AND    A,(HL)"); break;
   case 0xa7: sprintf(mnemonic, "AND    A,A"); break;
   case 0xa8: sprintf(mnemonic, "XOR    A,B"); break;
   case 0xa9: sprintf(mnemonic, "XOR    A,C"); break;
   case 0xaa: sprintf(mnemonic, "XOR    A,D"); break;
   case 0xab: sprintf(mnemonic, "XOR    A,E"); break;
   case 0xac: sprintf(mnemonic, "XOR    A,H"); break;
   case 0xad: sprintf(mnemonic, "XOR    A,L"); break;
   case 0xae: sprintf(mnemonic, "XOR    A,(HL)"); break;
   case 0xaf: sprintf(mnemonic, "XOR    A,A"); break;

   case 0xb0: sprintf(mnemonic, "OR     A,B"); break;
   case 0xb1: sprintf(mnemonic, "OR     A,C"); break;
   case 0xb2: sprintf(mnemonic, "OR     A,D"); break;
   case 0xb3: sprintf(mnemonic, "OR     A,E"); break;
   case 0xb4: sprintf(mnemonic, "OR     A,H"); break;
   case 0xb5: sprintf(mnemonic, "OR     A,L"); break;
   case 0xb6: sprintf(mnemonic, "OR     A,(HL)"); break;
   case 0xb7: sprintf(mnemonic, "OR     A,A"); break;
   case 0xb8: sprintf(mnemonic, "CP     A,B"); break;
   case 0xb9: sprintf(mnemonic, "CP     A,C"); break;
   case 0xba: sprintf(mnemonic, "CP     A,D"); break;
   case 0xbb: sprintf(mnemonic, "CP     A,E"); break;
   case 0xbc: sprintf(mnemonic, "CP     A,H"); break;
   case 0xbd: sprintf(mnemonic, "CP     A,L"); break;
   case 0xbe: sprintf(mnemonic, "CP     A,(HL)"); break;
   case 0xbf: sprintf(mnemonic, "CP     A,A"); break;

   case 0xc0: sprintf(mnemonic, "RET    NZ"); break;
   case 0xc1: sprintf(mnemonic, "POP    BC"); break;
   case 0xc2: sprintf(mnemonic, "JP     NZ,%s", functionName(address)); opbytes = 3; break; // JNZ
   case 0xc3: sprintf(mnemonic, "JP     %s", functionName(address)); opbytes = 3; break; // JMP
   case 0xc4: sprintf(mnemonic, "CALL   NZ,%s", functionName(address)); opbytes = 3; break; // CNZ
   case 0xc5: sprintf(mnemonic, "PUSH   BC"); break;
   case 0xc6: sprintf(mnemonic, "ADD    A,$%02x", value); opbytes = 2; break;
   case 0xc7: sprintf(mnemonic, "RST    0"); break;
   case 0xc8: sprintf(mnemonic, "RET    Z"); break; // RZ
   case 0xc9: sprintf(mnemonic, "RET"); break; // RET
   case 0xca: sprintf(mnemonic, "JP     Z,%s", functionName(address)); opbytes = 3; break; // JZ
   case 0xcb: sprintf(mnemonic, "NOP"); break; // unused
   case 0xcc: sprintf(mnemonic, "CALL   Z,%s", functionName(address)); opbytes = 3; break; // CZ
   case 0xcd: sprintf(mnemonic, "CALL   %s", functionName(address)); opbytes = 3; break; // CALL
   case 0xce: sprintf(mnemonic, "ADC    A,$%02x", value); opbytes = 2; break;
   case 0xcf: sprintf(mnemonic, "RST    1"); break;

   case 0xd0: sprintf(mnemonic, "RET    NC"); break; // RNC
   case 0xd1: sprintf(mnemonic, "POP    DE"); break;
   case 0xd2: sprintf(mnemonic, "JP     NC,%s", functionName(address)); opbytes = 3; break; // JNC
   case 0xd3: sprintf(mnemonic, "OUT    ($%02x),A", value); opbytes = 2; break;
   case 0xd4: sprintf(mnemonic, "CALL   NC,%s", functionName(address)); opbytes = 3; break; // CNC
   case 0xd5: sprintf(mnemonic, "PUSH   DE"); break;
   case 0xd6: sprintf(mnemonic, "SUB    A,$%02x", value); opbytes = 2; break;
   case 0xd7: sprintf(mnemonic, "RST    2"); break;
   case 0xd8: sprintf(mnemonic, "RET    C"); break; // RC
   case 0xd9: sprintf(mnemonic, "NOP"); break; // unused
   case 0xda: sprintf(mnemonic, "JP     C,%s", functionName(address)); opbytes = 3; break; // JC
   case 0xdb: sprintf(mnemonic, "IN     A,($%02x)", value); opbytes = 2; break;
   case 0xdc: sprintf(mnemonic, "CALL   C,%s", functionName(address)); opbytes = 3; break; // CC
   case 0xdd: sprintf(mnemonic, "NOP"); break; // unused
   case 0xde: sprintf(mnemonic, "SUB    A,$%02x", value); opbytes = 2; break;
   case 0xdf: sprintf(mnemonic, "RST    3"); break;

   case 0xe0: sprintf(mnemonic, "RET    PO"); break;
   case 0xe1: sprintf(mnemonic, "POP    HL"); break;
   case 0xe2: sprintf(mnemonic, "JP     PO,%s", functionName(address)); opbytes = 3; break; // RPO
   case 0xe3: sprintf(mnemonic, "EX     (SP),HL"); break;
   case 0xe4: sprintf(mnemonic, "CALL   PO,%s", functionName(address)); opbytes = 3; break; // CPO
   case 0xe5: sprintf(mnemonic, "PUSH   HL"); break;
   case 0xe6: sprintf(mnemonic, "AND    A,$%02x", value); opbytes = 2; break;
   case 0xe7: sprintf(mnemonic, "RST    4"); break;
   case 0xe8: sprintf(mnemonic, "RET    PE"); break; // RPE
   case 0xe9: sprintf(mnemonic, "JP     (HL)"); break; // PCHL
   case 0xea: sprintf(mnemonic, "JP     PE,%s", functionName(address)); opbytes = 3; break; // JPE
   case 0xeb: sprintf(mnemonic, "EX     DE,HL"); break; // XCHG
   case 0xec: sprintf(mnemonic, "CALL   PE,%s", functionName(address)); opbytes = 3; break; // CPE
   case 0xed: sprintf(mnemonic, "NOP"); break; // unused
   case 0xee: sprintf(mnemonic, "XOR    A,$%02x", value); opbytes = 2; break;
   case 0xef: sprintf(mnemonic, "RST    5"); break;

   case 0xf0: sprintf(mnemonic, "RET    P"); break;
   case 0xf1: sprintf(mnemonic, "POP    PSW"); break;
   case 0xf2: sprintf(mnemonic, "JP     P,%s", functionName(address)); opbytes = 3; break; // JP
   case 0xf3: sprintf(mnemonic, "DI"); break;
   case 0xf4: sprintf(mnemonic, "CALL   P,%s", functionName(address)); opbytes = 3; break; // CP
   case 0xf5: sprintf(mnemonic, "PUSH   PSW"); break;
   case 0xf6: sprintf(mnemonic, "OR     A,$%02x", value); opbytes = 2; break;
   case 0xf7: sprintf(mnemonic, "RST    6"); break;
   case 0xf8: sprintf(mnemonic, "RET    M"); break; // RM
   case 0xf9: sprintf(mnemonic, "LD     SP,HL"); break; // SPHL
   case 0xfa: sprintf(mnemonic, "JP     M,%s", functionName(address)); opbytes = 3; break; // JM
   case 0xfb: sprintf(mnemonic, "EI"); break;
   case 0xfc: sprintf(mnemonic, "CALL   M,%s", functionName(address)); opbytes = 3; break; // CM
   case 0xfd: sprintf(mnemonic, "NOP"); break; // unused
   case 0xfe: sprintf(mnemonic, "CP     $%02x", value); opbytes = 2; break;
   case 0xff: sprintf(mnemonic, "RST    7"); break;
   }

   printf("%-26s", mnemonic);

   return opbytes;
}

void State8080::displayAbrev()
{
   int A = Reg.a;
   int PSW
      = (Reg.f.s << 7)
      | (Reg.f.z << 6)
      | (0 << 5)
      | (Reg.f.a << 4)
      | (0 << 3)
      | (Reg.f.p << 2)
      | (1 << 1)
      | (Reg.f.c << 0);

   std::cout << std::dec;

   int BC = ((int)(Reg.b) << 8) | (Reg.c);
   int DE = ((int)(Reg.d) << 8) | (Reg.e);
   int HL = ((int)(Reg.h) << 8) | (Reg.l);
   int SP = ((int)(Reg.sp));

   std::cout << std::hex << std::setfill('0');
   std::cout
      << "PSW=" << std::setw(2) << PSW
      << " A=" << std::setw(2) << A
      << " BC=" << std::setw(4) << BC
      << " (DE=" << std::setw(4) << DE << ")=" << std::setw(2) << (int)memory->memory[DE]
      << " (HL=" << std::setw(4) << HL << ")=" << std::setw(2) << (int)memory->memory[HL]
      << " (SP=" << std::setw(4) << SP << ")=";
   if (0x2300 <= SP && SP < 0x2400) // Stack pointer must point to stack area
      std::cout << std::setw(4) << (int)(memory->memory[SP + 1] << 8 | memory->memory[SP]);
   std::cout << std::dec;
}

void State8080::displayFull()
{
   std::bitset<8> ab, bb, cb, db, eb, hb, lb;
   int ad, bd, cd, dd, ed, hd, ld;
   ab = ad = Reg.a;
   bb = bd = Reg.b;
   cb = cd = Reg.c;
   db = dd = Reg.d;
   eb = ed = Reg.e;
   hb = hd = Reg.h;
   lb = ld = Reg.l;

   //std::bitset<8> fb;
   //int fd;
   int fb
      = (Reg.f.s << 7)
      | (Reg.f.z << 6)
      | (0 << 5)
      | (Reg.f.a << 4)
      | (0 << 3)
      | (Reg.f.p << 2)
      | (1 << 1)
      | (Reg.f.c << 0);

   std::bitset<16> spb, pcb;
   int spd, pcd;
   spb = spd = Reg.sp;
   pcb = pcd = Reg.pc;

   std::cout << std::hex << std::endl;

   std::cout << "    FEDCBA98    76543210" << std::endl;

   std::cout << "PSW";
   std::cout << ab << "=" << std::setw(2) << ad << "";
   std::cout << fb << "";
   std::cout << "S=" << (Reg.f.s == 1 ? "1" : "0") << "";
   std::cout << "Z=" << (Reg.f.z == 1 ? "1" : "0") << "";
   std::cout << "A=" << (Reg.f.a == 1 ? "1" : "0") << "";
   std::cout << "P=" << (Reg.f.p == 1 ? "1" : "0") << "";
   std::cout << "C=" << (Reg.f.c == 1 ? "1" : "0") << std::endl;

   std::cout << "B  "
      << bb << "=" << std::setw(2) << bd << ""
      << cb << "=" << std::setw(2) << cd << std::endl;

   std::cout << "D  "
      << db << "=" << std::setw(2) << dd << ""
      << eb << "=" << std::setw(2) << ed << std::endl;

   std::cout << "H  "
      << hb << "=" << std::setw(2) << hd << ""
      << lb << "=" << std::setw(2) << ld << std::endl;


   std::cout << "    FEDCBA9876543210" << std::endl;
   std::cout << "SP " << spb << "=" << std::setw(4) << spd << std::endl;
   std::cout << "PC " << pcb << "=" << std::setw(4) << pcd << std::endl;

   std::cout << std::dec;
}

void State8080::report(std::ostream &stream)
{
   for (int opcode = 0; opcode < 256; opcode++)
      stream << opcode << "\t" << this->hitCount[opcode] << std::endl;
}