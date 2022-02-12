*HAN SUN, MONELLE DEGBE AND SAMEEH ULLAH
$TITLE CLOSED ECONOMY MODEL WITH GOVERNMENT: OTARKY_G
$EOLCOM #


SET N1 /LABOUR,CAPITAL,HOUSEH, FIRMS,  AGRIC,  EXTRACT,OIL_GAS,MANUF,  SERV,ACCUM, GOVMT,DIRECT_TX,INDIR_TX /
    I(N1) /AGRIC, EXTRACT, OIL_GAS, MANUF, SERV/
    I1(I) /AGRIC, EXTRACT, OIL_GAS, SERV /
    I2(I) /MANUF/
ALIAS (N1,N2)
ALIAS (I,J)


PARAMETERS

SAM2(N1, N2)            SAM data
VXTSO(J)                Value of total production of industry j in the benchmark situation (without production taxes)
VVAO(J)                 Value of value added of industry j in the benchmark situation
VINTO(J)                Value of total intermediate inputs used in industry j in the benchmark situation
VKO(J)                  Return to capital industry j in the benchmark situation
VLDO(J)                 Salaries paid by industry j in the benchmark situation
VVO(I,J)                Value of commodity i used as intermediate inputs in industry j in the benchmark situation
VDINVO(I)               Value of investment demand of commodity i (without taxes) in the benchmark situation
VCO(I)                  Value of household consumption of commodity i (without taxes) in the benchmark situation

XTSO(J)                 Volume of total production of industry j in the benchmark situation
VAO(J)                  Volume of value added of industry j in the benchmark situation
INTO(J)                 Volume of total intermediate inputs used in industry j in the benchmark situation
KO(J)                   Stock of capital industry j in the benchmark situation
LDO(J)                  Quantity of labour demand by industry j in the benchmark situation
VO(I,J)                 Volume of commodity i used as intermediate inputs in industry j in the benchmark situation
DINVO(I)                Volume of investment demand of commodity i in the benchmark situation
CO(I)                   Volume of household consumption of commodity i in the benchmark situation
GO(I)                   Volume of government  consumption of commodity i in the benchmark situation
LSO                     Total labour supply in the benchmark situation
KTOTO                   Total stock of capital in the benchmark situation
CHO                     Household consumption expenditures in the benchmark situation
SH                      Household average saving propensity
YTHO                    Household total income in the benchmark situation
BETAKH                  Share of total profits returned to households as dividend
YEO                     Firms' total income in the benchmark situation
SAV_HO                  Household savings in the benchmark situation
SAV_EO                  Firms' total savings in the benchmark situation
TOTSAVO                 Total savings in the benchmark
BETAV(I)                Share of commodity i in total investment expenditure
PXTSO(J)                Price of total production of industry j in the benchmark situation (net of production tax)
PVAO(J)                 Price of value added of industry j in the benchmark situation
PINTO(J)                Price of total intermediate inputs used in industry j in the benchmark situation
PCO(I)                  Purchase price of commodity i in the benchmark situation (without taxes)
RO                      Rental rate of capital in the benchmark situation
WO                      Wage rate in the benchmark situation

AP(J)                   Shift parameter in the c-D production function of industry j
ALPHAP(J)               Share parameter in the  c-D production function of industry j
SIGI(J)                 Elasticity of substitution in the  cES production function of industry j
AV(J)                   Shift parameter in the cES production function of value added in industry j
ALPHAV(J)               Share parameter in the cES production function of value added in industry j
AIJ(I,J)                Input-output coefficient in industry j
ALPHAC(I)               Share parameter in the household ces utility function
SIGV(J)                 Elasticity of substitution in the CES production function of industry j
SIGC                    Elasticity of substitution in the  household ces utility function
RESF                    RESCALING FACTOR

* addition (in comparison with the NO_GOV model )

VGO(I)                  Value of government consumption of commodity i in the benchmark situation (without taxes)
VINDTAXO(J)             Value of indirect taxes on output in industry j in the benchmark situation
TOTCONSTXO              Total indirect taxes on household consumption of commodities i in the benchmark situation
TOTGOVTXO               Total indirect taxes on government consumption of commodities i in the benchmark situation
TOTINVTXO               Total indirect taxes on investment goods i in the benchmark situation
TP(J)                   Production tax rate in industry j
TC(I)                   Household consumption tax rate on commodities i
TINV(I)                 Tax rate on investment good i
TG(I)                   Government consumption tax rate on commodities i
YDHO                    Household disposable income in the benchmark situation
YEO                     Firms' income in the benchmark situation
YGO                     Government total revenue in the benchmark situation
SAV_GO                  Government savings in the benchmark situation
TRGHO                   Government transfers to households in the benchmark situation
DIRTAX_HO               Household income tax in the benchmark situation
DIRTAX_EO               Corporate income tax in the benchmark situation
TY_H                    Household income tax rate
TY_E                    Corporate income tax rate

REPORT_TABLE_SECTOR(*,J)                REPORT TABLE FOR SECTORAL VARIABLES
REPORT_TABLE_SCALAR(*,*)                REPORT TABLE FOR SCALAR VARIABLES
CHECK(J)
;

*==================================
* Read the data in the Excel file
*==================================

$CALL GDXXRW.EXE  IO_SAM_2021.xlsx   O=SAM2.GDX    PAR=SAM2  rng=TAB_SAM2!A9:L22
$GDXIN SAM2.gdx
$LOAD SAM2
$GDXIN
;

*====================================
* Starting the model calibration
*====================================


* Rescale original data in the sam in order to ease the sovler's task

RESF =1000;
SAM2 (N1, N2) = SAM2 (N1, N2)/RESF ;

*=========================================
* Assigning values to external parameters
*=========================================

SIGI(J)         = 0.5;
SIGV(J)         = 0.8;
SIGC            = 0.9;          #CES preferences

*=========================================
* Assign values to parameters from the SAM
*=========================================

VLDO(J)         = SAM2('LABOUR',J);
VKO(J)          = SAM2('CAPITAL',J);
VINDTAXO(J)     = SAM2('INDIR_TX',J);
VVO(I,J)        = SAM2(I,J);
VDINVO(I)       = SAM2(I, 'ACCUM');
VCO(I)          = SAM2(I, 'HOUSEH');
VGO(I)          = SAM2(I, 'GOVMT');
SAV_HO          = SAM2('ACCUM', 'HOUSEH');
SAV_EO          = SAM2('ACCUM', 'FIRMS');
SAV_GO          = SAM2('ACCUM', 'GOVMT');

TOTCONSTXO      = SAM2('INDIR_TX', 'HOUSEH');
TOTGOVTXO       = SAM2('INDIR_TX', 'GOVMT');
TOTINVTXO       = SAM2('INDIR_TX', 'ACCUM');
DIRTAX_HO       = SAM2('DIRECT_TX', 'HOUSEH');
DIRTAX_EO       = SAM2('DIRECT_TX', 'FIRMS');
TRGHO           = SAM2('HOUSEH', 'GOVMT');


VVAO(J)         = VLDO(J) +  VKO(J) ;
VINTO(J)        = SUM[I, VVO(I,J)];
VXTSO(J)        = VVAO(J) + VINTO(J) ;


* By appropriate unit change prices could be set to unity in the benchmark

PXTSO(J)=1; PVAO(J) =1; PINTO(J)=1; RO=1; WO=1;

* Note that not all prices have been set to one because of the presence of taxes
* Calibrate the values of volumes and parameters from the transaction values in the SAM and from the prices;

XTSO(J) =       VXTSO(J)/PXTSO(J);
VAO(J)  =       VVAO(J)/PVAO(J);
INTO(J) =       VINTO(J)/PINTO(J);
KO(J)   =       VKO(J)/RO;
LDO(J)  =       VLDO(J)/WO;
LSO     =       SUM[J, LDO(J)];
KTOTO   =       SUM[J, KO(J)];
TP(J)   =       VINDTAXO(J)/(PXTSO(J)*XTSO(J));
PCO(I)  =       PXTSO(I)*(1+TP(I));             # User price before taxes on final demand
VO(I,J) =       VVO(I,J)/PCO(I);
CO(I)   =       VCO(I)/PCO(I);
GO(I)   =       VGO(I)/PCO(I);
DINVO(I)=       VDINVO(I)/PCO(I);
TC(I)   =       TOTCONSTXO / SUM[J,VCO(J)];
TINV(I) =       TOTINVTXO /SUM[J,VDINVO(J)];
TG(I)   =       TOTGOVTXO /SUM[J,VGO(J)];
CHO     =       SUM[I, PCO(I)*(1+TC(I))*CO(I)];
YDHO    =       CHO +  SAV_HO;
YTHO    =       YDHO + DIRTAX_HO ;
TY_H    =       DIRTAX_HO/ YTHO;
SH      =       SAV_HO/YDHO     ;
BETAKH  =       SAM2('HOUSEH', 'CAPITAL')/SUM[J, RO*KO(J)];
YEO     =       [1-BETAKH]*SUM[J, RO*KO(J)];
TY_E    =       DIRTAX_EO /  YEO;
YGO     =       DIRTAX_HO + DIRTAX_EO + SUM[J, VINDTAXO(J)] + TOTCONSTXO + TOTGOVTXO +  TOTINVTXO;
TOTSAVO =       SAV_EO + SAV_HO + SAV_GO        ;
BETAV(I)=       PCO(I)*[1+TINV(I)]*DINVO(I) /TOTSAVO    ;

ALPHAV(J)=      1/{ 1 + [WO/RO]*[LDO(J)/KO(J)]**(1/SIGV(J))};

AV(J) =         VAO(J)/{[ALPHAV(J)*KO(J)**(1-1/SIGV(J))]
                         +[(1-ALPHAV(J))*LDO(J)**(1-1/SIGV(J))]
                        }**[SIGV(J)/(SIGV(J)-1)];

ALPHAP(J) =     VAO(J)*PVAO(J)/PXTSO(J)/XTSO(J);

AP(J)   =       XTSO(J)/{[VAO(J)**ALPHAP(J)]*[INTO(J)**(1-ALPHAP(J))]}  ;

AIJ(I,J)=       VO(I,J)/INTO(J);

ALPHAC(I) =     {PCO(I)*[1+TC(I)]*[CO(I)]**(1/SIGC)}/
                SUM{J, PCO(J)*[1+TC(J)]*[CO(J)]**(1/SIGC)};



POSITIVE VARIABLES

C(I)                    Volume of household consumption of commodity i
CH                      Household consumption expenditures
DINV(I)                 Volume of investment demand of commodity i
G(I)                    Volume of government consumption of commodity i
INT(J)                  Volume of the index of intermediate inputs used in industry j
K(J)                    Stock of capital industry j
KTOT                    Total stock of capital
LD(J)                   Labour demand by industry j (volume)
LS                      Total labour supply (volume)
PC(I)                   Purchase price of commodity i
PINT(J)                 Index price of total intermediate inputs used in industry j
PVA(J)                  Price of value added of industry j
PXTS(J)                 Output price in industry j (net of production taxes)
PINDEX                  Index of producer price without tax
R                       Rental rate of capital
SAV_E                   Firm savings
SAV_H                   Household savings
TOTSAV                  Total savings
V(I,J)                  Volume of commodity i used as intermediate inputs in industry j
VA(J)                   Volume of value added of industry j
W                       Wage rate
XTS(J)                  Output in industry j
YDH                     Household disposable income
YE                      Corporate income
YG                      Government total revenue
YTH                     Household total income

;


FREE VARIABLES

TRGH                    Government transfers to households
SAV_G                   Government savings
WALRAS                  Dummy variable to check Walras law
OMEGA
TAX_SUPP                 TAXE SUPPLEMENTAIRE
;


EQUATIONS

CC(I)                   Household demand for commodity i
CCH                     Definition of household consumption expenditures
DDINV(I)                Demand for investment good i
IINT(J)                 Aggregate input of intermediate inputs used in industry j
KK(J)                   Demand for capital industry j
LLD(J)                  Demand for labour demand by industry j
PCC(I)                  Consumption price
PPINT(J)                Index price of inputs in industry j
PPVA(J)                 Value added price in industry j
PPXTS(J)                Price of output in industry j
SSAV_E                  Firm savings
SSAV_H                  Household savings
TTOTSAV                 Total savings
VV(I,J)                 Intermediate input demand in industry j
VVA(J)                  Value added of industry j
YYTH                    Household total income
PPINDEX                 INDEX OF PRODUCER PRICES WITHOUT TAX
EQ_XTS1(I)              Equilibrium condition for commodity i
EQ_XTS2(I)              Equilibrium condition for commodity i
EQCAP                   Equilibrium condition in capital market
EQLAB                   Equilibrium condition in labour market
OBJ

YYDH                    Household disposable income
YYE                     Corporate income
YYG                     Government income
SSAV_G                  Government savings

;




CC(I)..                 C(I) =E= {ALPHAC(I)/[PC(I)*(1+TC(I))]}**SIGC * CH /
                                SUM{J, ALPHAC(J)**SIGC*[PC(J)*(1+TC(J))]**(1-SIGC)};

CCH..                   CH      =E= (1-SH)*YDH;

YYDH..                  YDH     =E= (1-TY_H)*YTH;

YYTH..                  YTH     =E= W*SUM[J, LD(J)] + BETAKH*R*SUM[J, K(J)]  + TRGH;

SSAV_H..                SAV_H   =E= SH*YDH;

PPXTS(J)..              PXTS(J)=E= 1/AP(J)*    ( {PVA(J)/ALPHAP(J)}**ALPHAP(J))*(PINT(J)/(1-ALPHAP(J)))**(1-ALPHAP(J));

VVA(J)..                VA(J) =E= AP(J)*XTS(J)*PXTS(J)/PVA(J);

IINT(J)..               INT(J) =E= AP(J)*XTS(J)*PXTS(J)/PINT(J);

PPVA(J)..               PVA(J)          =E= 1/AV(J)*{ALPHAV(J)**SIGV(J)*[R**(1-SIGV(J))]+([1-ALPHAV(J)]**SIGV(J))*W**(1-SIGV(J))}**(1/(1-SIGV(J)));

KK(J)..                 K(J)            =E= {ALPHAV(J)**(SIGV(J)-1)}*VA(J)*(ALPHAV(J)*PVA(J)/R)**(SIGV(J));

LLD(J)..                LD(J)           =E= {ALPHAV(J)**(SIGV(J)-1)}*VA(J)*((1-ALPHAV(J))*PVA(J)/W)**(SIGV(J));

PPINT(J)..              PINT(J)**(1-SIGI(J)) =E= SUM[I, AIJ(I,J)*PC(I)];

VV(I,J)..               V(I,J) =E= AIJ(I,J)**(SIGI(J)-1)*INT(J)*(AIJ(I,J)*PINT(J)/PC(I))**SIGI(J);

YYE..                   YE =E= (1-BETAKH)*R*SUM[J, K(J)];

SSAV_E..                SAV_E =E= (1-TY_E)*YE;

YYG..                   YG      =E=       SUM{I, PC(I)*TC(I)*C(I)}
                                        + SUM{I, PC(I)*TG(I)*G(I)}
                                        + SUM{I, PC(I)*TINV(I)*DINV(I)}
                                        + SUM{J, PXTS(J)*TP(J)*XTS(J)}
                                        + TY_E*YE
                                        + TY_H*YTH
                                        ;

SSAV_G..                SAV_G   =E= YG - SUM{I, PC(I)*(1+TG(I))*G(I)} - TRGH;

TTOTSAV..               TOTSAV =E= SAV_E  + SAV_H + SAV_G;

DDINV(I)..              PC(I)*[1+TINV(I)]*DINV(I) =E= BETAV(I)*TOTSAV;

PCC(I)..                PC(I) =E= PXTS(I)*[1+TP(I)] ;

PPINDEX..               PINDEX   =E= SUM[J,XTSO(J)*PXTS(J)]/SUM[I,XTSO(I)];

EQ_XTS1(I1)..           XTS(I1) =E= C(I1) +  DINV(I1) + G(I1) + SUM[J, V(I1,J)]  ;

EQ_XTS2(I2)..           XTS(I2) =E= C(I2) +  DINV(I2) + G(I2) + SUM[J, V(I2,J)]  +WALRAS;

EQLAB..                 SUM[J, LD(J)] =E= LS;

EQCAP..                 SUM[J, K(J)] =E= KTOT;

OBJ..                   OMEGA =E= 10;





* VARIABLE INITIALIZATION

C.L(I)          =       CO(I)           ;               C.LO(I)         = 0.0001*        CO(I)           ;
CH.L            =       CHO             ;               CH.LO           = 0.0001*        CHO             ;
DINV.L(I)       =       DINVO(I)        ;               DINV.LO(I)      = 0.0001*        DINVO(I)        ;
INT.L(J)        =       INTO(J)         ;               INT.LO(J)       = 0.0001*        INTO(J)         ;
K.L(J)          =       KO(J)           ;               K.LO(J)         = 0.0001*        KO(J)           ;
LD.L(J)         =       LDO(J)          ;               LD.LO(J)        = 0.0001*        LDO(J)          ;
PC.L(I)         =       PCO(I)          ;               PC.LO(I)        = 0.0001*        PCO(I)          ;
PINT.L(J)       =       PINTO(J)        ;               PINT.LO(J)      = 0.0001*        PINTO(J)        ;
PVA.L(J)        =       PVAO(J)         ;               PVA.LO(J)       = 0.0001*        PVAO(J)         ;
PXTS.L(J)       =       PXTSO(J)        ;               PXTS.LO(J)      = 0.0001*       PXTSO(J)        ;
R.L             =       RO              ;               R.LO            = 0.0001*        RO              ;
SAV_E.L         =       SAV_EO          ;               SAV_E.LO        = 0.0001*        SAV_EO          ;
SAV_H.L         =       SAV_HO          ;               SAV_H.LO        = 0.0001*        SAV_HO          ;
TOTSAV.L        =       TOTSAVO         ;               TOTSAV.LO       = 0.0001*        TOTSAVO         ;
V.L(I,J)        =       VO(I,J)         ;               V.LO(I,J)       = 0.0001*        VO(I,J)         ;
VA.L(J)         =       VAO(J)          ;               VA.LO(J)        = 0.0001*        VAO(J)          ;
W.L             =       WO              ;               W.LO            = 0.0001*        WO              ;
XTS.L(J)        =       XTSO(J)         ;               XTS.LO(J)       = 0.0001*        XTSO(J)         ;
YTH.L           =       YTHO            ;               YTH.LO          = 0.0001*        YTHO            ;
YDH.L           =       YDHO            ;               YDH.LO          = 0.0001*        YDHO            ;
YG.L            =       YGO             ;               YG.LO           = 0.0001*        YGO             ;
YE.L            =       YEO             ;               YE.LO           = 0.0001*        YEO             ;
SAV_G.L         =       SAV_GO          ;
TRGH.L          =       TRGHO           ;


*==================
*   MODEL CLOSURE
*==================

*Numeraire and closure rules
*PXTS.FX("PINDEX")=PXTSO("PINDEX");
PINDEX.FX=1;
KTOT.FX=KTOTO;
LS.FX=LSO;
G.FX(I)=GO(I);

TRGH.FX=TRGHO*1.25;
*# FIX GOVERNMENT TRANSFER or
*SAV_G.FX =  SAV_GO          ;

*======================
* SIMULATION
*======================

*tc(i) =0;


MODEL OTARKY_G /ALL/;

OPTION ITERLIM=100000,RESLIM=1000000000,LIMCOL=1,LIMROW=1;
OPTION NLP=CONOPT;


OTARKY_G.holdfixed=1;

*=======================
* Solviong the model
*=======================

SOLVE OTARKY_G MAXIMIZING OMEGA USING NLP;


* PREPARE REPORT TABLES

PARAMETERS

*===========================================================================================
* PARAMETERS TO COMPUTE PERCENTAGE OR ABSOLUTE CHANGES FOR ENDOGENOUS VARIABLES OF INTEREST
*===========================================================================================

V_C(I)
V_CH
V_DINV(I)
V_INT(J)
V_K(J)
V_LD(J)
V_PC(I)
V_PINT(J)
V_PVA(J)
V_PXTS(J)
V_R
V_SAV_E
V_SAV_H
V_TOTSAV
V_VA(J)
V_W
V_XTS(J)
V_YTH
V_YG
V_SAV_G
V_TRGH

;

*===============================================================================
* COMPUTING THE PERCENTAGE CHANGES OF THE VARIABLES FROM THEIR BENCHMARK VALUES
*===============================================================================

V_C(I)          =[C.L(I)        /       CO(I)           -1]*100;
V_CH            =[CH.L          /       CHO             -1]*100;
V_DINV(I)       =[DINV.L(I)     /       DINVO(I)        -1]*100;
V_INT(J)        =[INT.L(J)      /       INTO(J)         -1]*100;
V_K(J)          =[K.L(J)        /       KO(J)           -1]*100;
V_LD(J)         =[LD.L(J)       /       LDO(J)          -1]*100;
V_PC(I)         =[PC.L(I)       /       PCO(I)          -1]*100;
V_PINT(J)       =[PINT.L(J)     /       PINTO(J)        -1]*100;
V_PVA(J)        =[PVA.L(J)      /       PVAO(J)         -1]*100;
V_PXTS(J)       =[PXTS.L(J)     /       PXTSO(J)        -1]*100;
V_R             =[R.L           /       RO              -1]*100;
V_SAV_E         =[SAV_E.L       /       SAV_EO          -1]*100;
V_SAV_H         =[SAV_H.L       /       SAV_HO          -1]*100;
V_SAV_G         =[SAV_G.L       -       SAV_GO          ]*100/YGO;
V_TOTSAV        =[TOTSAV.L      /       TOTSAVO         -1]*100;
V_VA(J)         =[VA.L(J)       /       VAO(J)          -1]*100;
V_W             =[W.L           /       WO              -1]*100;
V_XTS(J)        =[XTS.L(J)      /       XTSO(J)         -1]*100;
V_YTH           =[YTH.L         /       YTHO            -1]*100;
V_YG            =[YG.L          /       YGO             -1]*100;
V_TRGH          =[TRGH.L        /       TRGHO           -1]*100;



*==========================
* CREATE THE REPORT TABLES
*==========================

REPORT_TABLE_SECTOR("Output price",J)                           = V_PXTS(J);
REPORT_TABLE_SECTOR("Value added  price",J)                     = V_PVA(J);
REPORT_TABLE_SECTOR("Price of index of interm. inputs",J)       = V_PINT(J);

REPORT_TABLE_SECTOR("Output volume",J)                          = V_XTS(J);
REPORT_TABLE_SECTOR("Value added",J)                            = V_VA(J);
REPORT_TABLE_SECTOR("Index of interm. inputs",J)                = V_INT(J);
REPORT_TABLE_SECTOR("Demand for capital",J)                     = V_K(J);
REPORT_TABLE_SECTOR("Demand for labour",J)                      = V_LD(J);
REPORT_TABLE_SECTOR("Household demand",J)                       = V_C(J);
REPORT_TABLE_SECTOR("Demand for investment good",J)             = V_DINV(J);


REPORT_TABLE_SCALAR("Household income","% Change")              = V_YTH;
REPORT_TABLE_SCALAR("Household saving","% Change")              = V_SAV_H;
REPORT_TABLE_SCALAR("Firm saving","% Change")                   = V_SAV_E;
REPORT_TABLE_SCALAR("Rental rate of capital","% Change")        = V_R;
REPORT_TABLE_SCALAR("Wage rate","% Change")                     = V_W;
REPORT_TABLE_SCALAR("Government revenue","% Change")            = V_YG;;
REPORT_TABLE_SCALAR("Government savings","% Ch. of base rev.")  = V_SAV_G;
REPORT_TABLE_SCALAR("Total savings","% Change")                 = V_TOTSAV;
REPORT_TABLE_SCALAR("Transfers to households","% Change")                 = V_TRGH;




*============================================
* WRITE THE RESULTS TABLES IN AN EXCEL FILE
*============================================

EXECUTE_UNLOAD "OTARKY.GDX",  REPORT_TABLE_SECTOR, REPORT_TABLE_SCALAR;

Execute 'GDXXRW.EXE OTARKY.GDX O=OTARKY.XLS TEXT="SECTORAL RESULTS" rng=REPORT_TABLE!A3';
Execute 'GDXXRW.EXE OTARKY.GDX O=OTARKY.XLS PAR=REPORT_TABLE_SECTOR rng=REPORT_TABLE!A5';
Execute 'GDXXRW.EXE OTARKY.GDX O=OTARKY.XLS TEXT="AGGREGATE RESULTS" rng=REPORT_TABLE!M3';
Execute 'GDXXRW.EXE OTARKY.GDX O=OTARKY.XLS PAR=REPORT_TABLE_SCALAR rng=REPORT_TABLE!M5';


DISPLAY REPORT_TABLE_SECTOR, REPORT_TABLE_SCALAR;
