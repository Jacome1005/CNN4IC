module user_project_example (clk_i,
    rst_ni,
    ui_PAD2CORE,
    uo_CORE2PAD);
 input clk_i;
 input rst_ni;
 input [16:0] ui_PAD2CORE;
 output [16:0] uo_CORE2PAD;

 wire _000_;
 wire _001_;
 wire _002_;
 wire _003_;
 wire _004_;
 wire _005_;
 wire _006_;
 wire _007_;
 wire _008_;
 wire _009_;
 wire _010_;
 wire _011_;
 wire _012_;
 wire _013_;
 wire _014_;
 wire _015_;
 wire _016_;
 wire _017_;
 wire _018_;
 wire _019_;
 wire _020_;
 wire _021_;
 wire _022_;
 wire _023_;
 wire _024_;
 wire _025_;
 wire _026_;
 wire _027_;
 wire _028_;
 wire _029_;
 wire _030_;
 wire _031_;
 wire _032_;
 wire _033_;
 wire _034_;
 wire _035_;
 wire _036_;
 wire _037_;
 wire _038_;
 wire _039_;
 wire _040_;
 wire _041_;
 wire _042_;
 wire _043_;
 wire _044_;
 wire _045_;
 wire _046_;
 wire _047_;
 wire _048_;
 wire _049_;
 wire _050_;
 wire _051_;
 wire _052_;
 wire _053_;
 wire _054_;
 wire _055_;
 wire _056_;
 wire _057_;
 wire _058_;
 wire _059_;
 wire _060_;
 wire _061_;
 wire _062_;
 wire _063_;
 wire _064_;
 wire _065_;
 wire _066_;
 wire _067_;
 wire _068_;
 wire _069_;
 wire _070_;
 wire _071_;
 wire _072_;
 wire _073_;
 wire _074_;
 wire _075_;
 wire _076_;
 wire _077_;
 wire net1;
 wire \spm_inst.csa0.hsum2 ;
 wire \spm_inst.csa0.sc ;
 wire \spm_inst.csa0.sum ;
 wire \spm_inst.csa0.y ;
 wire \spm_inst.genblk1[10].csa.hsum2 ;
 wire \spm_inst.genblk1[10].csa.sc ;
 wire \spm_inst.genblk1[10].csa.sum ;
 wire \spm_inst.genblk1[10].csa.y ;
 wire \spm_inst.genblk1[11].csa.hsum2 ;
 wire \spm_inst.genblk1[11].csa.sc ;
 wire \spm_inst.genblk1[11].csa.y ;
 wire \spm_inst.genblk1[12].csa.hsum2 ;
 wire \spm_inst.genblk1[12].csa.sc ;
 wire \spm_inst.genblk1[12].csa.y ;
 wire \spm_inst.genblk1[13].csa.hsum2 ;
 wire \spm_inst.genblk1[13].csa.sc ;
 wire \spm_inst.genblk1[13].csa.y ;
 wire \spm_inst.genblk1[14].csa.hsum2 ;
 wire \spm_inst.genblk1[14].csa.sc ;
 wire \spm_inst.genblk1[14].csa.y ;
 wire \spm_inst.genblk1[1].csa.hsum2 ;
 wire \spm_inst.genblk1[1].csa.sc ;
 wire \spm_inst.genblk1[1].csa.y ;
 wire \spm_inst.genblk1[2].csa.hsum2 ;
 wire \spm_inst.genblk1[2].csa.sc ;
 wire \spm_inst.genblk1[2].csa.y ;
 wire \spm_inst.genblk1[3].csa.hsum2 ;
 wire \spm_inst.genblk1[3].csa.sc ;
 wire \spm_inst.genblk1[3].csa.y ;
 wire \spm_inst.genblk1[4].csa.hsum2 ;
 wire \spm_inst.genblk1[4].csa.sc ;
 wire \spm_inst.genblk1[4].csa.y ;
 wire \spm_inst.genblk1[5].csa.hsum2 ;
 wire \spm_inst.genblk1[5].csa.sc ;
 wire \spm_inst.genblk1[5].csa.y ;
 wire \spm_inst.genblk1[6].csa.hsum2 ;
 wire \spm_inst.genblk1[6].csa.sc ;
 wire \spm_inst.genblk1[6].csa.y ;
 wire \spm_inst.genblk1[7].csa.hsum2 ;
 wire \spm_inst.genblk1[7].csa.sc ;
 wire \spm_inst.genblk1[7].csa.y ;
 wire \spm_inst.genblk1[8].csa.hsum2 ;
 wire \spm_inst.genblk1[8].csa.sc ;
 wire \spm_inst.genblk1[8].csa.y ;
 wire \spm_inst.genblk1[9].csa.hsum2 ;
 wire \spm_inst.genblk1[9].csa.sc ;
 wire \spm_inst.tcmp.z ;
 wire net2;
 wire net3;
 wire net4;
 wire net5;
 wire net6;
 wire net7;
 wire net8;
 wire net9;
 wire net10;
 wire net11;
 wire net12;
 wire net13;
 wire net14;
 wire net15;
 wire net16;
 wire net17;
 wire net18;
 wire net19;
 wire net35;
 wire net36;
 wire net37;
 wire net38;
 wire net39;
 wire net40;
 wire net41;
 wire clknet_0_clk_i;
 wire net27;
 wire net28;
 wire net29;
 wire net30;
 wire net31;
 wire net32;
 wire net33;
 wire net34;
 wire net20;
 wire net21;
 wire net22;
 wire net23;
 wire net24;
 wire net25;
 wire net26;
 wire net;
 wire clknet_3_0__leaf_clk_i;
 wire clknet_3_1__leaf_clk_i;
 wire clknet_3_2__leaf_clk_i;
 wire clknet_3_3__leaf_clk_i;
 wire clknet_3_4__leaf_clk_i;
 wire clknet_3_5__leaf_clk_i;
 wire clknet_3_6__leaf_clk_i;
 wire clknet_3_7__leaf_clk_i;
 wire net42;
 wire net43;
 wire net44;
 wire net45;
 wire net46;
 wire net47;
 wire net48;
 wire net49;
 wire net50;
 wire net51;
 wire net52;
 wire net53;
 wire net54;
 wire net55;
 wire net56;
 wire net57;
 wire net58;
 wire net59;
 wire net60;
 wire net61;
 wire net62;
 wire net63;
 wire net64;
 wire net65;
 wire net66;
 wire net67;
 wire net68;
 wire net69;
 wire net70;
 wire net71;
 wire net72;
 wire net73;
 wire net74;
 wire net75;
 wire net76;
 wire net77;
 wire net78;
 wire net79;
 wire net80;
 wire net81;
 wire net82;
 wire net83;
 wire net84;
 wire net85;
 wire net86;
 wire net87;
 wire net88;
 wire net89;
 wire net90;
 wire net91;
 wire net92;
 wire net93;
 wire net94;
 wire net95;
 wire net96;
 wire net97;
 wire net98;
 wire net99;
 wire net100;
 wire net101;
 wire net102;

 sg13g2_nand2_1 _078_ (.Y(_065_),
    .A(net20),
    .B(net8));
 sg13g2_nand2_1 _079_ (.Y(_066_),
    .A(net43),
    .B(\spm_inst.genblk1[14].csa.y ));
 sg13g2_nor2_1 _080_ (.A(net43),
    .B(\spm_inst.genblk1[14].csa.y ),
    .Y(_067_));
 sg13g2_xor2_1 _081_ (.B(net95),
    .A(net43),
    .X(_068_));
 sg13g2_xnor2_1 _082_ (.Y(\spm_inst.genblk1[14].csa.hsum2 ),
    .A(_065_),
    .B(_068_));
 sg13g2_o21ai_1 _083_ (.B1(net44),
    .Y(_005_),
    .A1(_065_),
    .A2(_067_));
 sg13g2_nand2_1 _084_ (.Y(_069_),
    .A(net7),
    .B(net20));
 sg13g2_nand2_1 _085_ (.Y(_070_),
    .A(net52),
    .B(\spm_inst.genblk1[13].csa.y ));
 sg13g2_nor2_1 _086_ (.A(net52),
    .B(\spm_inst.genblk1[13].csa.y ),
    .Y(_071_));
 sg13g2_xor2_1 _087_ (.B(net94),
    .A(net52),
    .X(_072_));
 sg13g2_xnor2_1 _088_ (.Y(\spm_inst.genblk1[13].csa.hsum2 ),
    .A(_069_),
    .B(_072_));
 sg13g2_o21ai_1 _089_ (.B1(net53),
    .Y(_004_),
    .A1(_069_),
    .A2(_071_));
 sg13g2_nand2_1 _090_ (.Y(_073_),
    .A(net20),
    .B(net6));
 sg13g2_nand2_1 _091_ (.Y(_074_),
    .A(net46),
    .B(\spm_inst.genblk1[12].csa.y ));
 sg13g2_nor2_1 _092_ (.A(net46),
    .B(\spm_inst.genblk1[12].csa.y ),
    .Y(_075_));
 sg13g2_xor2_1 _093_ (.B(net93),
    .A(net46),
    .X(_076_));
 sg13g2_xnor2_1 _094_ (.Y(\spm_inst.genblk1[12].csa.hsum2 ),
    .A(_073_),
    .B(_076_));
 sg13g2_o21ai_1 _095_ (.B1(net47),
    .Y(_003_),
    .A1(_073_),
    .A2(_075_));
 sg13g2_nand2_1 _096_ (.Y(_077_),
    .A(net20),
    .B(net5));
 sg13g2_nand2_1 _097_ (.Y(_017_),
    .A(net85),
    .B(\spm_inst.genblk1[11].csa.y ));
 sg13g2_nor2_1 _098_ (.A(net85),
    .B(\spm_inst.genblk1[11].csa.y ),
    .Y(_018_));
 sg13g2_xor2_1 _099_ (.B(net96),
    .A(net85),
    .X(_019_));
 sg13g2_xnor2_1 _100_ (.Y(\spm_inst.genblk1[11].csa.hsum2 ),
    .A(_077_),
    .B(_019_));
 sg13g2_o21ai_1 _101_ (.B1(net86),
    .Y(_002_),
    .A1(_077_),
    .A2(_018_));
 sg13g2_nand2_1 _102_ (.Y(_020_),
    .A(net21),
    .B(net4));
 sg13g2_nand2_1 _103_ (.Y(_021_),
    .A(net67),
    .B(\spm_inst.genblk1[10].csa.y ));
 sg13g2_nor2_1 _104_ (.A(net67),
    .B(\spm_inst.genblk1[10].csa.y ),
    .Y(_022_));
 sg13g2_xor2_1 _105_ (.B(net102),
    .A(net67),
    .X(_023_));
 sg13g2_xnor2_1 _106_ (.Y(\spm_inst.genblk1[10].csa.hsum2 ),
    .A(_020_),
    .B(_023_));
 sg13g2_o21ai_1 _107_ (.B1(net68),
    .Y(_001_),
    .A1(_020_),
    .A2(_022_));
 sg13g2_nand2_1 _108_ (.Y(_024_),
    .A(net21),
    .B(net3));
 sg13g2_nand2_1 _109_ (.Y(_025_),
    .A(net79),
    .B(\spm_inst.genblk1[10].csa.sum ));
 sg13g2_nor2_1 _110_ (.A(net79),
    .B(\spm_inst.genblk1[10].csa.sum ),
    .Y(_026_));
 sg13g2_xor2_1 _111_ (.B(net92),
    .A(net79),
    .X(_027_));
 sg13g2_xnor2_1 _112_ (.Y(\spm_inst.genblk1[9].csa.hsum2 ),
    .A(_024_),
    .B(_027_));
 sg13g2_o21ai_1 _113_ (.B1(net80),
    .Y(_014_),
    .A1(_024_),
    .A2(_026_));
 sg13g2_nand2_1 _114_ (.Y(_028_),
    .A(net21),
    .B(net18));
 sg13g2_nand2_1 _115_ (.Y(_029_),
    .A(net73),
    .B(\spm_inst.genblk1[8].csa.y ));
 sg13g2_nor2_1 _116_ (.A(net73),
    .B(\spm_inst.genblk1[8].csa.y ),
    .Y(_030_));
 sg13g2_xor2_1 _117_ (.B(net91),
    .A(net73),
    .X(_031_));
 sg13g2_xnor2_1 _118_ (.Y(\spm_inst.genblk1[8].csa.hsum2 ),
    .A(_028_),
    .B(_031_));
 sg13g2_o21ai_1 _119_ (.B1(net74),
    .Y(_013_),
    .A1(_028_),
    .A2(_030_));
 sg13g2_nand2_1 _120_ (.Y(_032_),
    .A(net20),
    .B(net17));
 sg13g2_nand2_1 _121_ (.Y(_033_),
    .A(net58),
    .B(\spm_inst.genblk1[7].csa.y ));
 sg13g2_nor2_1 _122_ (.A(net58),
    .B(\spm_inst.genblk1[7].csa.y ),
    .Y(_034_));
 sg13g2_xor2_1 _123_ (.B(net99),
    .A(net58),
    .X(_035_));
 sg13g2_xnor2_1 _124_ (.Y(\spm_inst.genblk1[7].csa.hsum2 ),
    .A(_032_),
    .B(_035_));
 sg13g2_o21ai_1 _125_ (.B1(net59),
    .Y(_012_),
    .A1(_032_),
    .A2(_034_));
 sg13g2_nand2_1 _126_ (.Y(_036_),
    .A(net20),
    .B(net16));
 sg13g2_nand2_1 _127_ (.Y(_037_),
    .A(net61),
    .B(\spm_inst.genblk1[6].csa.y ));
 sg13g2_nor2_1 _128_ (.A(net61),
    .B(\spm_inst.genblk1[6].csa.y ),
    .Y(_038_));
 sg13g2_xor2_1 _129_ (.B(net98),
    .A(net61),
    .X(_039_));
 sg13g2_xnor2_1 _130_ (.Y(\spm_inst.genblk1[6].csa.hsum2 ),
    .A(_036_),
    .B(_039_));
 sg13g2_o21ai_1 _131_ (.B1(net62),
    .Y(_011_),
    .A1(_036_),
    .A2(_038_));
 sg13g2_nand2_1 _132_ (.Y(_040_),
    .A(net20),
    .B(net15));
 sg13g2_nand2_1 _133_ (.Y(_041_),
    .A(net64),
    .B(\spm_inst.genblk1[5].csa.y ));
 sg13g2_nor2_1 _134_ (.A(net64),
    .B(\spm_inst.genblk1[5].csa.y ),
    .Y(_042_));
 sg13g2_xor2_1 _135_ (.B(net97),
    .A(net64),
    .X(_043_));
 sg13g2_xnor2_1 _136_ (.Y(\spm_inst.genblk1[5].csa.hsum2 ),
    .A(_040_),
    .B(_043_));
 sg13g2_o21ai_1 _137_ (.B1(net65),
    .Y(_010_),
    .A1(_040_),
    .A2(_042_));
 sg13g2_nand2_1 _138_ (.Y(_044_),
    .A(net21),
    .B(net14));
 sg13g2_nand2_1 _139_ (.Y(_045_),
    .A(net49),
    .B(\spm_inst.genblk1[4].csa.y ));
 sg13g2_nor2_1 _140_ (.A(net49),
    .B(\spm_inst.genblk1[4].csa.y ),
    .Y(_046_));
 sg13g2_xor2_1 _141_ (.B(net89),
    .A(net49),
    .X(_047_));
 sg13g2_xnor2_1 _142_ (.Y(\spm_inst.genblk1[4].csa.hsum2 ),
    .A(_044_),
    .B(_047_));
 sg13g2_o21ai_1 _143_ (.B1(net50),
    .Y(_009_),
    .A1(_044_),
    .A2(_046_));
 sg13g2_nand2_1 _144_ (.Y(_048_),
    .A(net21),
    .B(net13));
 sg13g2_nand2_1 _145_ (.Y(_049_),
    .A(\spm_inst.genblk1[3].csa.sc ),
    .B(net76));
 sg13g2_nor2_1 _146_ (.A(\spm_inst.genblk1[3].csa.sc ),
    .B(net76),
    .Y(_050_));
 sg13g2_xor2_1 _147_ (.B(net76),
    .A(net88),
    .X(_051_));
 sg13g2_xnor2_1 _148_ (.Y(\spm_inst.genblk1[3].csa.hsum2 ),
    .A(_048_),
    .B(_051_));
 sg13g2_o21ai_1 _149_ (.B1(net77),
    .Y(_008_),
    .A1(_048_),
    .A2(_050_));
 sg13g2_nand2_1 _150_ (.Y(_052_),
    .A(net21),
    .B(net12));
 sg13g2_nand2_1 _151_ (.Y(_053_),
    .A(net55),
    .B(\spm_inst.genblk1[2].csa.y ));
 sg13g2_nor2_1 _152_ (.A(net55),
    .B(\spm_inst.genblk1[2].csa.y ),
    .Y(_054_));
 sg13g2_xor2_1 _153_ (.B(net90),
    .A(net55),
    .X(_055_));
 sg13g2_xnor2_1 _154_ (.Y(\spm_inst.genblk1[2].csa.hsum2 ),
    .A(_052_),
    .B(_055_));
 sg13g2_o21ai_1 _155_ (.B1(net56),
    .Y(_007_),
    .A1(_052_),
    .A2(_054_));
 sg13g2_nand2_1 _156_ (.Y(_056_),
    .A(net21),
    .B(net11));
 sg13g2_nand2_1 _157_ (.Y(_057_),
    .A(net82),
    .B(\spm_inst.genblk1[1].csa.y ));
 sg13g2_nor2_1 _158_ (.A(net82),
    .B(\spm_inst.genblk1[1].csa.y ),
    .Y(_058_));
 sg13g2_xor2_1 _159_ (.B(net101),
    .A(net82),
    .X(_059_));
 sg13g2_xnor2_1 _160_ (.Y(\spm_inst.genblk1[1].csa.hsum2 ),
    .A(_056_),
    .B(_059_));
 sg13g2_o21ai_1 _161_ (.B1(net83),
    .Y(_006_),
    .A1(_056_),
    .A2(_058_));
 sg13g2_nand2_1 _162_ (.Y(_060_),
    .A(net20),
    .B(net9));
 sg13g2_nand2b_1 _163_ (.Y(_016_),
    .B(_060_),
    .A_N(net42));
 sg13g2_xnor2_1 _164_ (.Y(_015_),
    .A(net42),
    .B(_060_));
 sg13g2_nand2_1 _165_ (.Y(_061_),
    .A(net21),
    .B(net10));
 sg13g2_nand2_1 _166_ (.Y(_062_),
    .A(net70),
    .B(\spm_inst.csa0.y ));
 sg13g2_nor2_1 _167_ (.A(net70),
    .B(\spm_inst.csa0.y ),
    .Y(_063_));
 sg13g2_xor2_1 _168_ (.B(net100),
    .A(net70),
    .X(_064_));
 sg13g2_xnor2_1 _169_ (.Y(\spm_inst.csa0.hsum2 ),
    .A(_061_),
    .B(_064_));
 sg13g2_o21ai_1 _170_ (.B1(net71),
    .Y(_000_),
    .A1(_061_),
    .A2(_063_));
 sg13g2_dfrbpq_1 _171_ (.RESET_B(net22),
    .D(net45),
    .Q(\spm_inst.genblk1[14].csa.sc ),
    .CLK(clknet_3_2__leaf_clk_i));
 sg13g2_dfrbpq_1 _172_ (.RESET_B(net22),
    .D(\spm_inst.genblk1[14].csa.hsum2 ),
    .Q(\spm_inst.genblk1[13].csa.y ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _173_ (.RESET_B(net23),
    .D(net54),
    .Q(\spm_inst.genblk1[13].csa.sc ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _174_ (.RESET_B(net23),
    .D(\spm_inst.genblk1[13].csa.hsum2 ),
    .Q(\spm_inst.genblk1[12].csa.y ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _175_ (.RESET_B(net23),
    .D(net48),
    .Q(\spm_inst.genblk1[12].csa.sc ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _176_ (.RESET_B(net23),
    .D(\spm_inst.genblk1[12].csa.hsum2 ),
    .Q(\spm_inst.genblk1[11].csa.y ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _177_ (.RESET_B(net23),
    .D(net87),
    .Q(\spm_inst.genblk1[11].csa.sc ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _178_ (.RESET_B(net23),
    .D(\spm_inst.genblk1[11].csa.hsum2 ),
    .Q(\spm_inst.genblk1[10].csa.y ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _179_ (.RESET_B(net24),
    .D(net69),
    .Q(\spm_inst.genblk1[10].csa.sc ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _180_ (.RESET_B(net24),
    .D(\spm_inst.genblk1[10].csa.hsum2 ),
    .Q(\spm_inst.genblk1[10].csa.sum ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _181_ (.RESET_B(net24),
    .D(net81),
    .Q(\spm_inst.genblk1[9].csa.sc ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _182_ (.RESET_B(net24),
    .D(\spm_inst.genblk1[9].csa.hsum2 ),
    .Q(\spm_inst.genblk1[8].csa.y ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _183_ (.RESET_B(net25),
    .D(net75),
    .Q(\spm_inst.genblk1[8].csa.sc ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _184_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[8].csa.hsum2 ),
    .Q(\spm_inst.genblk1[7].csa.y ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _185_ (.RESET_B(net23),
    .D(net60),
    .Q(\spm_inst.genblk1[7].csa.sc ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _186_ (.RESET_B(net22),
    .D(\spm_inst.genblk1[7].csa.hsum2 ),
    .Q(\spm_inst.genblk1[6].csa.y ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _187_ (.RESET_B(net22),
    .D(net63),
    .Q(\spm_inst.genblk1[6].csa.sc ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _188_ (.RESET_B(net22),
    .D(\spm_inst.genblk1[6].csa.hsum2 ),
    .Q(\spm_inst.genblk1[5].csa.y ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _189_ (.RESET_B(net22),
    .D(net66),
    .Q(\spm_inst.genblk1[5].csa.sc ),
    .CLK(clknet_3_2__leaf_clk_i));
 sg13g2_dfrbpq_1 _190_ (.RESET_B(net26),
    .D(\spm_inst.genblk1[5].csa.hsum2 ),
    .Q(\spm_inst.genblk1[4].csa.y ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _191_ (.RESET_B(net25),
    .D(net51),
    .Q(\spm_inst.genblk1[4].csa.sc ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _192_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[4].csa.hsum2 ),
    .Q(\spm_inst.genblk1[3].csa.y ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _193_ (.RESET_B(net25),
    .D(net78),
    .Q(\spm_inst.genblk1[3].csa.sc ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _194_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[3].csa.hsum2 ),
    .Q(\spm_inst.genblk1[2].csa.y ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _195_ (.RESET_B(net25),
    .D(net57),
    .Q(\spm_inst.genblk1[2].csa.sc ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _196_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[2].csa.hsum2 ),
    .Q(\spm_inst.genblk1[1].csa.y ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _197_ (.RESET_B(net24),
    .D(net84),
    .Q(\spm_inst.genblk1[1].csa.sc ),
    .CLK(clknet_3_5__leaf_clk_i));
 sg13g2_dfrbpq_1 _198_ (.RESET_B(net24),
    .D(\spm_inst.genblk1[1].csa.hsum2 ),
    .Q(\spm_inst.csa0.y ),
    .CLK(clknet_3_5__leaf_clk_i));
 sg13g2_dfrbpq_1 _199_ (.RESET_B(net22),
    .D(_015_),
    .Q(\spm_inst.genblk1[14].csa.y ),
    .CLK(clknet_3_2__leaf_clk_i));
 sg13g2_dfrbpq_1 _200_ (.RESET_B(net22),
    .D(_016_),
    .Q(\spm_inst.tcmp.z ),
    .CLK(clknet_3_2__leaf_clk_i));
 sg13g2_dfrbpq_1 _201_ (.RESET_B(net24),
    .D(net72),
    .Q(\spm_inst.csa0.sc ),
    .CLK(clknet_3_5__leaf_clk_i));
 sg13g2_dfrbpq_1 _202_ (.RESET_B(net24),
    .D(\spm_inst.csa0.hsum2 ),
    .Q(\spm_inst.csa0.sum ),
    .CLK(clknet_3_5__leaf_clk_i));
 sg13g2_buf_16 clkbuf_0_clk_i (.X(clknet_0_clk_i),
    .A(clk_i));
 sg13g2_tielo user_project_example_27 (.L_LO(net27));
 sg13g2_tielo user_project_example_28 (.L_LO(net28));
 sg13g2_tielo user_project_example_29 (.L_LO(net29));
 sg13g2_tielo user_project_example_30 (.L_LO(net30));
 sg13g2_tielo user_project_example_31 (.L_LO(net31));
 sg13g2_tielo user_project_example_32 (.L_LO(net32));
 sg13g2_tielo user_project_example_33 (.L_LO(net33));
 sg13g2_tielo user_project_example_34 (.L_LO(net34));
 sg13g2_tielo user_project_example_35 (.L_LO(net35));
 sg13g2_tielo user_project_example_36 (.L_LO(net36));
 sg13g2_tielo user_project_example_37 (.L_LO(net37));
 sg13g2_tielo user_project_example_38 (.L_LO(net38));
 sg13g2_tielo user_project_example_39 (.L_LO(net39));
 sg13g2_tielo user_project_example_40 (.L_LO(net40));
 sg13g2_tiehi user_project_example_41 (.L_HI(net41));
 sg13g2_buf_1 _219_ (.A(\spm_inst.csa0.sum ),
    .X(net19));
 sg13g2_buf_1 input1 (.A(rst_ni),
    .X(net1));
 sg13g2_buf_1 input2 (.A(ui_PAD2CORE[0]),
    .X(net2));
 sg13g2_buf_1 input3 (.A(ui_PAD2CORE[10]),
    .X(net3));
 sg13g2_buf_1 input4 (.A(ui_PAD2CORE[11]),
    .X(net4));
 sg13g2_buf_1 input5 (.A(ui_PAD2CORE[12]),
    .X(net5));
 sg13g2_buf_1 input6 (.A(ui_PAD2CORE[13]),
    .X(net6));
 sg13g2_buf_1 input7 (.A(ui_PAD2CORE[14]),
    .X(net7));
 sg13g2_buf_1 input8 (.A(ui_PAD2CORE[15]),
    .X(net8));
 sg13g2_buf_1 input9 (.A(ui_PAD2CORE[16]),
    .X(net9));
 sg13g2_buf_1 input10 (.A(ui_PAD2CORE[1]),
    .X(net10));
 sg13g2_buf_1 input11 (.A(ui_PAD2CORE[2]),
    .X(net11));
 sg13g2_buf_1 input12 (.A(ui_PAD2CORE[3]),
    .X(net12));
 sg13g2_buf_1 input13 (.A(ui_PAD2CORE[4]),
    .X(net13));
 sg13g2_buf_1 input14 (.A(ui_PAD2CORE[5]),
    .X(net14));
 sg13g2_buf_1 input15 (.A(ui_PAD2CORE[6]),
    .X(net15));
 sg13g2_buf_1 input16 (.A(ui_PAD2CORE[7]),
    .X(net16));
 sg13g2_buf_1 input17 (.A(ui_PAD2CORE[8]),
    .X(net17));
 sg13g2_buf_1 input18 (.A(ui_PAD2CORE[9]),
    .X(net18));
 sg13g2_buf_1 output19 (.A(net19),
    .X(uo_CORE2PAD[0]));
 sg13g2_buf_1 fanout20 (.A(net2),
    .X(net20));
 sg13g2_buf_1 fanout21 (.A(net2),
    .X(net21));
 sg13g2_buf_1 fanout22 (.A(net23),
    .X(net22));
 sg13g2_buf_1 fanout23 (.A(net26),
    .X(net23));
 sg13g2_buf_1 fanout24 (.A(net26),
    .X(net24));
 sg13g2_buf_1 fanout25 (.A(net26),
    .X(net25));
 sg13g2_buf_1 fanout26 (.A(net1),
    .X(net26));
 sg13g2_tielo user_project_example (.L_LO(net));
 sg13g2_buf_16 clkbuf_3_0__f_clk_i (.X(clknet_3_0__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_buf_16 clkbuf_3_1__f_clk_i (.X(clknet_3_1__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_buf_16 clkbuf_3_2__f_clk_i (.X(clknet_3_2__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_buf_16 clkbuf_3_3__f_clk_i (.X(clknet_3_3__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_buf_16 clkbuf_3_4__f_clk_i (.X(clknet_3_4__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_buf_16 clkbuf_3_5__f_clk_i (.X(clknet_3_5__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_buf_16 clkbuf_3_6__f_clk_i (.X(clknet_3_6__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_buf_16 clkbuf_3_7__f_clk_i (.X(clknet_3_7__leaf_clk_i),
    .A(clknet_0_clk_i));
 sg13g2_dlygate4sd3_1 hold42 (.A(\spm_inst.tcmp.z ),
    .X(net42));
 sg13g2_dlygate4sd3_1 hold43 (.A(\spm_inst.genblk1[14].csa.sc ),
    .X(net43));
 sg13g2_dlygate4sd3_1 hold44 (.A(_066_),
    .X(net44));
 sg13g2_dlygate4sd3_1 hold45 (.A(_005_),
    .X(net45));
 sg13g2_dlygate4sd3_1 hold46 (.A(\spm_inst.genblk1[12].csa.sc ),
    .X(net46));
 sg13g2_dlygate4sd3_1 hold47 (.A(_074_),
    .X(net47));
 sg13g2_dlygate4sd3_1 hold48 (.A(_003_),
    .X(net48));
 sg13g2_dlygate4sd3_1 hold49 (.A(\spm_inst.genblk1[4].csa.sc ),
    .X(net49));
 sg13g2_dlygate4sd3_1 hold50 (.A(_045_),
    .X(net50));
 sg13g2_dlygate4sd3_1 hold51 (.A(_009_),
    .X(net51));
 sg13g2_dlygate4sd3_1 hold52 (.A(\spm_inst.genblk1[13].csa.sc ),
    .X(net52));
 sg13g2_dlygate4sd3_1 hold53 (.A(_070_),
    .X(net53));
 sg13g2_dlygate4sd3_1 hold54 (.A(_004_),
    .X(net54));
 sg13g2_dlygate4sd3_1 hold55 (.A(\spm_inst.genblk1[2].csa.sc ),
    .X(net55));
 sg13g2_dlygate4sd3_1 hold56 (.A(_053_),
    .X(net56));
 sg13g2_dlygate4sd3_1 hold57 (.A(_007_),
    .X(net57));
 sg13g2_dlygate4sd3_1 hold58 (.A(\spm_inst.genblk1[7].csa.sc ),
    .X(net58));
 sg13g2_dlygate4sd3_1 hold59 (.A(_033_),
    .X(net59));
 sg13g2_dlygate4sd3_1 hold60 (.A(_012_),
    .X(net60));
 sg13g2_dlygate4sd3_1 hold61 (.A(\spm_inst.genblk1[6].csa.sc ),
    .X(net61));
 sg13g2_dlygate4sd3_1 hold62 (.A(_037_),
    .X(net62));
 sg13g2_dlygate4sd3_1 hold63 (.A(_011_),
    .X(net63));
 sg13g2_dlygate4sd3_1 hold64 (.A(\spm_inst.genblk1[5].csa.sc ),
    .X(net64));
 sg13g2_dlygate4sd3_1 hold65 (.A(_041_),
    .X(net65));
 sg13g2_dlygate4sd3_1 hold66 (.A(_010_),
    .X(net66));
 sg13g2_dlygate4sd3_1 hold67 (.A(\spm_inst.genblk1[10].csa.sc ),
    .X(net67));
 sg13g2_dlygate4sd3_1 hold68 (.A(_021_),
    .X(net68));
 sg13g2_dlygate4sd3_1 hold69 (.A(_001_),
    .X(net69));
 sg13g2_dlygate4sd3_1 hold70 (.A(\spm_inst.csa0.sc ),
    .X(net70));
 sg13g2_dlygate4sd3_1 hold71 (.A(_062_),
    .X(net71));
 sg13g2_dlygate4sd3_1 hold72 (.A(_000_),
    .X(net72));
 sg13g2_dlygate4sd3_1 hold73 (.A(\spm_inst.genblk1[8].csa.sc ),
    .X(net73));
 sg13g2_dlygate4sd3_1 hold74 (.A(_029_),
    .X(net74));
 sg13g2_dlygate4sd3_1 hold75 (.A(_013_),
    .X(net75));
 sg13g2_dlygate4sd3_1 hold76 (.A(\spm_inst.genblk1[3].csa.y ),
    .X(net76));
 sg13g2_dlygate4sd3_1 hold77 (.A(_049_),
    .X(net77));
 sg13g2_dlygate4sd3_1 hold78 (.A(_008_),
    .X(net78));
 sg13g2_dlygate4sd3_1 hold79 (.A(\spm_inst.genblk1[9].csa.sc ),
    .X(net79));
 sg13g2_dlygate4sd3_1 hold80 (.A(_025_),
    .X(net80));
 sg13g2_dlygate4sd3_1 hold81 (.A(_014_),
    .X(net81));
 sg13g2_dlygate4sd3_1 hold82 (.A(\spm_inst.genblk1[1].csa.sc ),
    .X(net82));
 sg13g2_dlygate4sd3_1 hold83 (.A(_057_),
    .X(net83));
 sg13g2_dlygate4sd3_1 hold84 (.A(_006_),
    .X(net84));
 sg13g2_dlygate4sd3_1 hold85 (.A(\spm_inst.genblk1[11].csa.sc ),
    .X(net85));
 sg13g2_dlygate4sd3_1 hold86 (.A(_017_),
    .X(net86));
 sg13g2_dlygate4sd3_1 hold87 (.A(_002_),
    .X(net87));
 sg13g2_dlygate4sd3_1 hold88 (.A(\spm_inst.genblk1[3].csa.sc ),
    .X(net88));
 sg13g2_dlygate4sd3_1 hold89 (.A(\spm_inst.genblk1[4].csa.y ),
    .X(net89));
 sg13g2_dlygate4sd3_1 hold90 (.A(\spm_inst.genblk1[2].csa.y ),
    .X(net90));
 sg13g2_dlygate4sd3_1 hold91 (.A(\spm_inst.genblk1[8].csa.y ),
    .X(net91));
 sg13g2_dlygate4sd3_1 hold92 (.A(\spm_inst.genblk1[10].csa.sum ),
    .X(net92));
 sg13g2_dlygate4sd3_1 hold93 (.A(\spm_inst.genblk1[12].csa.y ),
    .X(net93));
 sg13g2_dlygate4sd3_1 hold94 (.A(\spm_inst.genblk1[13].csa.y ),
    .X(net94));
 sg13g2_dlygate4sd3_1 hold95 (.A(\spm_inst.genblk1[14].csa.y ),
    .X(net95));
 sg13g2_dlygate4sd3_1 hold96 (.A(\spm_inst.genblk1[11].csa.y ),
    .X(net96));
 sg13g2_dlygate4sd3_1 hold97 (.A(\spm_inst.genblk1[5].csa.y ),
    .X(net97));
 sg13g2_dlygate4sd3_1 hold98 (.A(\spm_inst.genblk1[6].csa.y ),
    .X(net98));
 sg13g2_dlygate4sd3_1 hold99 (.A(\spm_inst.genblk1[7].csa.y ),
    .X(net99));
 sg13g2_dlygate4sd3_1 hold100 (.A(\spm_inst.csa0.y ),
    .X(net100));
 sg13g2_dlygate4sd3_1 hold101 (.A(\spm_inst.genblk1[1].csa.y ),
    .X(net101));
 sg13g2_dlygate4sd3_1 hold102 (.A(\spm_inst.genblk1[10].csa.y ),
    .X(net102));
 sg13g2_decap_8 FILLER_0_4 ();
 sg13g2_decap_8 FILLER_0_11 ();
 sg13g2_decap_8 FILLER_0_18 ();
 sg13g2_decap_8 FILLER_0_25 ();
 sg13g2_decap_8 FILLER_0_32 ();
 sg13g2_decap_4 FILLER_0_39 ();
 sg13g2_fill_1 FILLER_0_43 ();
 sg13g2_decap_8 FILLER_0_65 ();
 sg13g2_decap_8 FILLER_0_72 ();
 sg13g2_fill_2 FILLER_0_79 ();
 sg13g2_decap_8 FILLER_0_89 ();
 sg13g2_decap_8 FILLER_0_96 ();
 sg13g2_decap_8 FILLER_0_103 ();
 sg13g2_decap_8 FILLER_0_110 ();
 sg13g2_decap_8 FILLER_0_117 ();
 sg13g2_decap_4 FILLER_0_124 ();
 sg13g2_fill_1 FILLER_0_128 ();
 sg13g2_fill_1 FILLER_0_149 ();
 sg13g2_decap_8 FILLER_1_12 ();
 sg13g2_decap_4 FILLER_1_19 ();
 sg13g2_fill_1 FILLER_1_23 ();
 sg13g2_decap_8 FILLER_1_28 ();
 sg13g2_fill_2 FILLER_1_35 ();
 sg13g2_fill_1 FILLER_1_37 ();
 sg13g2_fill_1 FILLER_1_68 ();
 sg13g2_fill_2 FILLER_1_93 ();
 sg13g2_fill_1 FILLER_1_95 ();
 sg13g2_decap_8 FILLER_1_105 ();
 sg13g2_decap_8 FILLER_1_112 ();
 sg13g2_decap_4 FILLER_1_119 ();
 sg13g2_fill_2 FILLER_1_123 ();
 sg13g2_decap_8 FILLER_2_8 ();
 sg13g2_fill_1 FILLER_2_15 ();
 sg13g2_fill_2 FILLER_2_39 ();
 sg13g2_fill_1 FILLER_2_41 ();
 sg13g2_decap_8 FILLER_2_105 ();
 sg13g2_decap_4 FILLER_2_112 ();
 sg13g2_fill_1 FILLER_2_116 ();
 sg13g2_fill_1 FILLER_2_149 ();
 sg13g2_decap_8 FILLER_3_0 ();
 sg13g2_fill_1 FILLER_3_7 ();
 sg13g2_fill_2 FILLER_3_70 ();
 sg13g2_fill_2 FILLER_3_108 ();
 sg13g2_fill_1 FILLER_3_110 ();
 sg13g2_fill_2 FILLER_3_138 ();
 sg13g2_fill_1 FILLER_3_140 ();
 sg13g2_fill_2 FILLER_4_33 ();
 sg13g2_fill_1 FILLER_4_35 ();
 sg13g2_decap_8 FILLER_4_97 ();
 sg13g2_decap_8 FILLER_4_104 ();
 sg13g2_fill_1 FILLER_4_111 ();
 sg13g2_fill_2 FILLER_4_147 ();
 sg13g2_fill_1 FILLER_4_149 ();
 sg13g2_fill_2 FILLER_5_4 ();
 sg13g2_fill_1 FILLER_5_10 ();
 sg13g2_decap_8 FILLER_5_47 ();
 sg13g2_decap_8 FILLER_5_54 ();
 sg13g2_decap_4 FILLER_5_61 ();
 sg13g2_fill_1 FILLER_5_65 ();
 sg13g2_fill_2 FILLER_5_75 ();
 sg13g2_fill_1 FILLER_5_108 ();
 sg13g2_decap_8 FILLER_6_41 ();
 sg13g2_decap_4 FILLER_6_48 ();
 sg13g2_decap_4 FILLER_6_60 ();
 sg13g2_fill_2 FILLER_6_64 ();
 sg13g2_fill_1 FILLER_6_111 ();
 sg13g2_fill_2 FILLER_6_139 ();
 sg13g2_decap_4 FILLER_7_36 ();
 sg13g2_fill_2 FILLER_7_40 ();
 sg13g2_fill_2 FILLER_7_56 ();
 sg13g2_fill_1 FILLER_7_58 ();
 sg13g2_fill_2 FILLER_7_113 ();
 sg13g2_fill_1 FILLER_8_0 ();
 sg13g2_fill_2 FILLER_8_37 ();
 sg13g2_fill_1 FILLER_8_39 ();
 sg13g2_decap_4 FILLER_8_75 ();
 sg13g2_fill_1 FILLER_8_140 ();
 sg13g2_fill_1 FILLER_9_0 ();
 sg13g2_fill_2 FILLER_9_36 ();
 sg13g2_fill_1 FILLER_9_38 ();
 sg13g2_fill_1 FILLER_9_107 ();
 sg13g2_fill_2 FILLER_9_121 ();
 sg13g2_fill_1 FILLER_9_123 ();
 sg13g2_fill_1 FILLER_10_4 ();
 sg13g2_decap_8 FILLER_10_29 ();
 sg13g2_decap_4 FILLER_10_36 ();
 sg13g2_fill_1 FILLER_10_40 ();
 sg13g2_fill_1 FILLER_10_76 ();
 sg13g2_fill_2 FILLER_10_148 ();
 sg13g2_decap_8 FILLER_11_0 ();
 sg13g2_fill_2 FILLER_11_7 ();
 sg13g2_fill_2 FILLER_11_36 ();
 sg13g2_fill_1 FILLER_11_38 ();
 sg13g2_fill_2 FILLER_11_77 ();
 sg13g2_fill_1 FILLER_11_79 ();
 sg13g2_fill_2 FILLER_11_107 ();
 sg13g2_fill_2 FILLER_11_118 ();
 sg13g2_fill_1 FILLER_11_120 ();
 sg13g2_fill_2 FILLER_11_138 ();
 sg13g2_fill_1 FILLER_11_140 ();
 sg13g2_fill_1 FILLER_12_0 ();
 sg13g2_fill_2 FILLER_12_45 ();
 sg13g2_fill_2 FILLER_12_74 ();
 sg13g2_fill_1 FILLER_12_76 ();
 sg13g2_fill_1 FILLER_12_111 ();
 sg13g2_fill_2 FILLER_12_143 ();
 sg13g2_fill_1 FILLER_12_145 ();
 sg13g2_decap_4 FILLER_13_4 ();
 sg13g2_fill_1 FILLER_13_8 ();
 sg13g2_fill_2 FILLER_13_22 ();
 sg13g2_decap_8 FILLER_13_28 ();
 sg13g2_decap_8 FILLER_13_35 ();
 sg13g2_fill_2 FILLER_13_42 ();
 sg13g2_fill_2 FILLER_13_67 ();
 sg13g2_fill_2 FILLER_13_112 ();
 sg13g2_fill_1 FILLER_13_114 ();
 sg13g2_decap_4 FILLER_14_35 ();
 sg13g2_fill_2 FILLER_14_39 ();
 sg13g2_fill_1 FILLER_14_68 ();
 sg13g2_fill_2 FILLER_14_100 ();
 sg13g2_fill_1 FILLER_14_102 ();
 sg13g2_fill_1 FILLER_14_107 ();
 sg13g2_fill_1 FILLER_14_124 ();
 sg13g2_fill_2 FILLER_15_0 ();
 sg13g2_fill_1 FILLER_15_2 ();
 sg13g2_decap_8 FILLER_15_30 ();
 sg13g2_fill_2 FILLER_15_37 ();
 sg13g2_fill_1 FILLER_15_39 ();
 sg13g2_fill_1 FILLER_15_67 ();
 sg13g2_fill_1 FILLER_15_136 ();
 sg13g2_decap_4 FILLER_16_52 ();
 sg13g2_fill_1 FILLER_16_83 ();
 sg13g2_decap_8 FILLER_16_101 ();
 sg13g2_fill_2 FILLER_16_108 ();
 sg13g2_fill_1 FILLER_16_110 ();
 sg13g2_fill_2 FILLER_16_147 ();
 sg13g2_fill_1 FILLER_16_149 ();
 sg13g2_fill_2 FILLER_17_13 ();
 sg13g2_decap_8 FILLER_17_19 ();
 sg13g2_decap_8 FILLER_17_26 ();
 sg13g2_decap_4 FILLER_17_33 ();
 sg13g2_fill_2 FILLER_17_37 ();
 sg13g2_decap_4 FILLER_17_69 ();
 sg13g2_decap_8 FILLER_17_98 ();
 sg13g2_decap_8 FILLER_17_105 ();
 sg13g2_decap_8 FILLER_17_112 ();
 sg13g2_fill_1 FILLER_17_119 ();
 sg13g2_fill_1 FILLER_17_134 ();
 sg13g2_fill_2 FILLER_17_139 ();
 sg13g2_fill_1 FILLER_17_141 ();
 sg13g2_decap_8 FILLER_18_12 ();
 sg13g2_decap_8 FILLER_18_19 ();
 sg13g2_decap_8 FILLER_18_26 ();
 sg13g2_decap_8 FILLER_18_33 ();
 sg13g2_fill_2 FILLER_18_40 ();
 sg13g2_fill_1 FILLER_18_62 ();
 sg13g2_decap_8 FILLER_18_72 ();
 sg13g2_decap_8 FILLER_18_87 ();
 sg13g2_decap_8 FILLER_18_94 ();
 sg13g2_decap_8 FILLER_18_101 ();
 sg13g2_decap_8 FILLER_18_108 ();
 sg13g2_decap_8 FILLER_18_115 ();
 sg13g2_decap_4 FILLER_18_122 ();
 assign uo_CORE2PAD[10] = net34;
 assign uo_CORE2PAD[11] = net35;
 assign uo_CORE2PAD[12] = net36;
 assign uo_CORE2PAD[13] = net37;
 assign uo_CORE2PAD[14] = net38;
 assign uo_CORE2PAD[15] = net39;
 assign uo_CORE2PAD[16] = net40;
 assign uo_CORE2PAD[1] = net41;
 assign uo_CORE2PAD[2] = net;
 assign uo_CORE2PAD[3] = net27;
 assign uo_CORE2PAD[4] = net28;
 assign uo_CORE2PAD[5] = net29;
 assign uo_CORE2PAD[6] = net30;
 assign uo_CORE2PAD[7] = net31;
 assign uo_CORE2PAD[8] = net32;
 assign uo_CORE2PAD[9] = net33;
endmodule
