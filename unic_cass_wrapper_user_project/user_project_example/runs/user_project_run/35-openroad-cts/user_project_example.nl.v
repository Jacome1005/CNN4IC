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

 sg13g2_nand2_1 _078_ (.Y(_065_),
    .A(net20),
    .B(net8));
 sg13g2_nand2_1 _079_ (.Y(_066_),
    .A(\spm_inst.genblk1[14].csa.sc ),
    .B(\spm_inst.genblk1[14].csa.y ));
 sg13g2_nor2_1 _080_ (.A(\spm_inst.genblk1[14].csa.sc ),
    .B(\spm_inst.genblk1[14].csa.y ),
    .Y(_067_));
 sg13g2_xor2_1 _081_ (.B(\spm_inst.genblk1[14].csa.y ),
    .A(\spm_inst.genblk1[14].csa.sc ),
    .X(_068_));
 sg13g2_xnor2_1 _082_ (.Y(\spm_inst.genblk1[14].csa.hsum2 ),
    .A(_065_),
    .B(_068_));
 sg13g2_o21ai_1 _083_ (.B1(_066_),
    .Y(_005_),
    .A1(_065_),
    .A2(_067_));
 sg13g2_nand2_1 _084_ (.Y(_069_),
    .A(net7),
    .B(net20));
 sg13g2_nand2_1 _085_ (.Y(_070_),
    .A(\spm_inst.genblk1[13].csa.sc ),
    .B(\spm_inst.genblk1[13].csa.y ));
 sg13g2_nor2_1 _086_ (.A(\spm_inst.genblk1[13].csa.sc ),
    .B(\spm_inst.genblk1[13].csa.y ),
    .Y(_071_));
 sg13g2_xor2_1 _087_ (.B(\spm_inst.genblk1[13].csa.y ),
    .A(\spm_inst.genblk1[13].csa.sc ),
    .X(_072_));
 sg13g2_xnor2_1 _088_ (.Y(\spm_inst.genblk1[13].csa.hsum2 ),
    .A(_069_),
    .B(_072_));
 sg13g2_o21ai_1 _089_ (.B1(_070_),
    .Y(_004_),
    .A1(_069_),
    .A2(_071_));
 sg13g2_nand2_1 _090_ (.Y(_073_),
    .A(net20),
    .B(net6));
 sg13g2_nand2_1 _091_ (.Y(_074_),
    .A(\spm_inst.genblk1[12].csa.sc ),
    .B(\spm_inst.genblk1[12].csa.y ));
 sg13g2_nor2_1 _092_ (.A(\spm_inst.genblk1[12].csa.sc ),
    .B(\spm_inst.genblk1[12].csa.y ),
    .Y(_075_));
 sg13g2_xor2_1 _093_ (.B(\spm_inst.genblk1[12].csa.y ),
    .A(\spm_inst.genblk1[12].csa.sc ),
    .X(_076_));
 sg13g2_xnor2_1 _094_ (.Y(\spm_inst.genblk1[12].csa.hsum2 ),
    .A(_073_),
    .B(_076_));
 sg13g2_o21ai_1 _095_ (.B1(_074_),
    .Y(_003_),
    .A1(_073_),
    .A2(_075_));
 sg13g2_nand2_1 _096_ (.Y(_077_),
    .A(net20),
    .B(net5));
 sg13g2_nand2_1 _097_ (.Y(_017_),
    .A(\spm_inst.genblk1[11].csa.sc ),
    .B(\spm_inst.genblk1[11].csa.y ));
 sg13g2_nor2_1 _098_ (.A(\spm_inst.genblk1[11].csa.sc ),
    .B(\spm_inst.genblk1[11].csa.y ),
    .Y(_018_));
 sg13g2_xor2_1 _099_ (.B(\spm_inst.genblk1[11].csa.y ),
    .A(\spm_inst.genblk1[11].csa.sc ),
    .X(_019_));
 sg13g2_xnor2_1 _100_ (.Y(\spm_inst.genblk1[11].csa.hsum2 ),
    .A(_077_),
    .B(_019_));
 sg13g2_o21ai_1 _101_ (.B1(_017_),
    .Y(_002_),
    .A1(_077_),
    .A2(_018_));
 sg13g2_nand2_1 _102_ (.Y(_020_),
    .A(net21),
    .B(net4));
 sg13g2_nand2_1 _103_ (.Y(_021_),
    .A(\spm_inst.genblk1[10].csa.sc ),
    .B(\spm_inst.genblk1[10].csa.y ));
 sg13g2_nor2_1 _104_ (.A(\spm_inst.genblk1[10].csa.sc ),
    .B(\spm_inst.genblk1[10].csa.y ),
    .Y(_022_));
 sg13g2_xor2_1 _105_ (.B(\spm_inst.genblk1[10].csa.y ),
    .A(\spm_inst.genblk1[10].csa.sc ),
    .X(_023_));
 sg13g2_xnor2_1 _106_ (.Y(\spm_inst.genblk1[10].csa.hsum2 ),
    .A(_020_),
    .B(_023_));
 sg13g2_o21ai_1 _107_ (.B1(_021_),
    .Y(_001_),
    .A1(_020_),
    .A2(_022_));
 sg13g2_nand2_1 _108_ (.Y(_024_),
    .A(net21),
    .B(net3));
 sg13g2_nand2_1 _109_ (.Y(_025_),
    .A(\spm_inst.genblk1[9].csa.sc ),
    .B(\spm_inst.genblk1[10].csa.sum ));
 sg13g2_nor2_1 _110_ (.A(\spm_inst.genblk1[9].csa.sc ),
    .B(\spm_inst.genblk1[10].csa.sum ),
    .Y(_026_));
 sg13g2_xor2_1 _111_ (.B(\spm_inst.genblk1[10].csa.sum ),
    .A(\spm_inst.genblk1[9].csa.sc ),
    .X(_027_));
 sg13g2_xnor2_1 _112_ (.Y(\spm_inst.genblk1[9].csa.hsum2 ),
    .A(_024_),
    .B(_027_));
 sg13g2_o21ai_1 _113_ (.B1(_025_),
    .Y(_014_),
    .A1(_024_),
    .A2(_026_));
 sg13g2_nand2_1 _114_ (.Y(_028_),
    .A(net21),
    .B(net18));
 sg13g2_nand2_1 _115_ (.Y(_029_),
    .A(\spm_inst.genblk1[8].csa.sc ),
    .B(\spm_inst.genblk1[8].csa.y ));
 sg13g2_nor2_1 _116_ (.A(\spm_inst.genblk1[8].csa.sc ),
    .B(\spm_inst.genblk1[8].csa.y ),
    .Y(_030_));
 sg13g2_xor2_1 _117_ (.B(\spm_inst.genblk1[8].csa.y ),
    .A(\spm_inst.genblk1[8].csa.sc ),
    .X(_031_));
 sg13g2_xnor2_1 _118_ (.Y(\spm_inst.genblk1[8].csa.hsum2 ),
    .A(_028_),
    .B(_031_));
 sg13g2_o21ai_1 _119_ (.B1(_029_),
    .Y(_013_),
    .A1(_028_),
    .A2(_030_));
 sg13g2_nand2_1 _120_ (.Y(_032_),
    .A(net20),
    .B(net17));
 sg13g2_nand2_1 _121_ (.Y(_033_),
    .A(\spm_inst.genblk1[7].csa.sc ),
    .B(\spm_inst.genblk1[7].csa.y ));
 sg13g2_nor2_1 _122_ (.A(\spm_inst.genblk1[7].csa.sc ),
    .B(\spm_inst.genblk1[7].csa.y ),
    .Y(_034_));
 sg13g2_xor2_1 _123_ (.B(\spm_inst.genblk1[7].csa.y ),
    .A(\spm_inst.genblk1[7].csa.sc ),
    .X(_035_));
 sg13g2_xnor2_1 _124_ (.Y(\spm_inst.genblk1[7].csa.hsum2 ),
    .A(_032_),
    .B(_035_));
 sg13g2_o21ai_1 _125_ (.B1(_033_),
    .Y(_012_),
    .A1(_032_),
    .A2(_034_));
 sg13g2_nand2_1 _126_ (.Y(_036_),
    .A(net20),
    .B(net16));
 sg13g2_nand2_1 _127_ (.Y(_037_),
    .A(\spm_inst.genblk1[6].csa.sc ),
    .B(\spm_inst.genblk1[6].csa.y ));
 sg13g2_nor2_1 _128_ (.A(\spm_inst.genblk1[6].csa.sc ),
    .B(\spm_inst.genblk1[6].csa.y ),
    .Y(_038_));
 sg13g2_xor2_1 _129_ (.B(\spm_inst.genblk1[6].csa.y ),
    .A(\spm_inst.genblk1[6].csa.sc ),
    .X(_039_));
 sg13g2_xnor2_1 _130_ (.Y(\spm_inst.genblk1[6].csa.hsum2 ),
    .A(_036_),
    .B(_039_));
 sg13g2_o21ai_1 _131_ (.B1(_037_),
    .Y(_011_),
    .A1(_036_),
    .A2(_038_));
 sg13g2_nand2_1 _132_ (.Y(_040_),
    .A(net20),
    .B(net15));
 sg13g2_nand2_1 _133_ (.Y(_041_),
    .A(\spm_inst.genblk1[5].csa.sc ),
    .B(\spm_inst.genblk1[5].csa.y ));
 sg13g2_nor2_1 _134_ (.A(\spm_inst.genblk1[5].csa.sc ),
    .B(\spm_inst.genblk1[5].csa.y ),
    .Y(_042_));
 sg13g2_xor2_1 _135_ (.B(\spm_inst.genblk1[5].csa.y ),
    .A(\spm_inst.genblk1[5].csa.sc ),
    .X(_043_));
 sg13g2_xnor2_1 _136_ (.Y(\spm_inst.genblk1[5].csa.hsum2 ),
    .A(_040_),
    .B(_043_));
 sg13g2_o21ai_1 _137_ (.B1(_041_),
    .Y(_010_),
    .A1(_040_),
    .A2(_042_));
 sg13g2_nand2_1 _138_ (.Y(_044_),
    .A(net21),
    .B(net14));
 sg13g2_nand2_1 _139_ (.Y(_045_),
    .A(\spm_inst.genblk1[4].csa.sc ),
    .B(\spm_inst.genblk1[4].csa.y ));
 sg13g2_nor2_1 _140_ (.A(\spm_inst.genblk1[4].csa.sc ),
    .B(\spm_inst.genblk1[4].csa.y ),
    .Y(_046_));
 sg13g2_xor2_1 _141_ (.B(\spm_inst.genblk1[4].csa.y ),
    .A(\spm_inst.genblk1[4].csa.sc ),
    .X(_047_));
 sg13g2_xnor2_1 _142_ (.Y(\spm_inst.genblk1[4].csa.hsum2 ),
    .A(_044_),
    .B(_047_));
 sg13g2_o21ai_1 _143_ (.B1(_045_),
    .Y(_009_),
    .A1(_044_),
    .A2(_046_));
 sg13g2_nand2_1 _144_ (.Y(_048_),
    .A(net21),
    .B(net13));
 sg13g2_nand2_1 _145_ (.Y(_049_),
    .A(\spm_inst.genblk1[3].csa.sc ),
    .B(\spm_inst.genblk1[3].csa.y ));
 sg13g2_nor2_1 _146_ (.A(\spm_inst.genblk1[3].csa.sc ),
    .B(\spm_inst.genblk1[3].csa.y ),
    .Y(_050_));
 sg13g2_xor2_1 _147_ (.B(\spm_inst.genblk1[3].csa.y ),
    .A(\spm_inst.genblk1[3].csa.sc ),
    .X(_051_));
 sg13g2_xnor2_1 _148_ (.Y(\spm_inst.genblk1[3].csa.hsum2 ),
    .A(_048_),
    .B(_051_));
 sg13g2_o21ai_1 _149_ (.B1(_049_),
    .Y(_008_),
    .A1(_048_),
    .A2(_050_));
 sg13g2_nand2_1 _150_ (.Y(_052_),
    .A(net21),
    .B(net12));
 sg13g2_nand2_1 _151_ (.Y(_053_),
    .A(\spm_inst.genblk1[2].csa.sc ),
    .B(\spm_inst.genblk1[2].csa.y ));
 sg13g2_nor2_1 _152_ (.A(\spm_inst.genblk1[2].csa.sc ),
    .B(\spm_inst.genblk1[2].csa.y ),
    .Y(_054_));
 sg13g2_xor2_1 _153_ (.B(\spm_inst.genblk1[2].csa.y ),
    .A(\spm_inst.genblk1[2].csa.sc ),
    .X(_055_));
 sg13g2_xnor2_1 _154_ (.Y(\spm_inst.genblk1[2].csa.hsum2 ),
    .A(_052_),
    .B(_055_));
 sg13g2_o21ai_1 _155_ (.B1(_053_),
    .Y(_007_),
    .A1(_052_),
    .A2(_054_));
 sg13g2_nand2_1 _156_ (.Y(_056_),
    .A(net21),
    .B(net11));
 sg13g2_nand2_1 _157_ (.Y(_057_),
    .A(\spm_inst.genblk1[1].csa.sc ),
    .B(\spm_inst.genblk1[1].csa.y ));
 sg13g2_nor2_1 _158_ (.A(\spm_inst.genblk1[1].csa.sc ),
    .B(\spm_inst.genblk1[1].csa.y ),
    .Y(_058_));
 sg13g2_xor2_1 _159_ (.B(\spm_inst.genblk1[1].csa.y ),
    .A(\spm_inst.genblk1[1].csa.sc ),
    .X(_059_));
 sg13g2_xnor2_1 _160_ (.Y(\spm_inst.genblk1[1].csa.hsum2 ),
    .A(_056_),
    .B(_059_));
 sg13g2_o21ai_1 _161_ (.B1(_057_),
    .Y(_006_),
    .A1(_056_),
    .A2(_058_));
 sg13g2_nand2_1 _162_ (.Y(_060_),
    .A(net20),
    .B(net9));
 sg13g2_nand2b_1 _163_ (.Y(_016_),
    .B(_060_),
    .A_N(\spm_inst.tcmp.z ));
 sg13g2_xnor2_1 _164_ (.Y(_015_),
    .A(\spm_inst.tcmp.z ),
    .B(_060_));
 sg13g2_nand2_1 _165_ (.Y(_061_),
    .A(net21),
    .B(net10));
 sg13g2_nand2_1 _166_ (.Y(_062_),
    .A(\spm_inst.csa0.sc ),
    .B(\spm_inst.csa0.y ));
 sg13g2_nor2_1 _167_ (.A(\spm_inst.csa0.sc ),
    .B(\spm_inst.csa0.y ),
    .Y(_063_));
 sg13g2_xor2_1 _168_ (.B(\spm_inst.csa0.y ),
    .A(\spm_inst.csa0.sc ),
    .X(_064_));
 sg13g2_xnor2_1 _169_ (.Y(\spm_inst.csa0.hsum2 ),
    .A(_061_),
    .B(_064_));
 sg13g2_o21ai_1 _170_ (.B1(_062_),
    .Y(_000_),
    .A1(_061_),
    .A2(_063_));
 sg13g2_dfrbpq_1 _171_ (.RESET_B(net22),
    .D(_005_),
    .Q(\spm_inst.genblk1[14].csa.sc ),
    .CLK(clknet_3_2__leaf_clk_i));
 sg13g2_dfrbpq_1 _172_ (.RESET_B(net22),
    .D(\spm_inst.genblk1[14].csa.hsum2 ),
    .Q(\spm_inst.genblk1[13].csa.y ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _173_ (.RESET_B(net23),
    .D(_004_),
    .Q(\spm_inst.genblk1[13].csa.sc ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _174_ (.RESET_B(net23),
    .D(\spm_inst.genblk1[13].csa.hsum2 ),
    .Q(\spm_inst.genblk1[12].csa.y ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _175_ (.RESET_B(net23),
    .D(_003_),
    .Q(\spm_inst.genblk1[12].csa.sc ),
    .CLK(clknet_3_0__leaf_clk_i));
 sg13g2_dfrbpq_1 _176_ (.RESET_B(net23),
    .D(\spm_inst.genblk1[12].csa.hsum2 ),
    .Q(\spm_inst.genblk1[11].csa.y ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _177_ (.RESET_B(net23),
    .D(_002_),
    .Q(\spm_inst.genblk1[11].csa.sc ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _178_ (.RESET_B(net23),
    .D(\spm_inst.genblk1[11].csa.hsum2 ),
    .Q(\spm_inst.genblk1[10].csa.y ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _179_ (.RESET_B(net24),
    .D(_001_),
    .Q(\spm_inst.genblk1[10].csa.sc ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _180_ (.RESET_B(net24),
    .D(\spm_inst.genblk1[10].csa.hsum2 ),
    .Q(\spm_inst.genblk1[10].csa.sum ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _181_ (.RESET_B(net24),
    .D(_014_),
    .Q(\spm_inst.genblk1[9].csa.sc ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _182_ (.RESET_B(net24),
    .D(\spm_inst.genblk1[9].csa.hsum2 ),
    .Q(\spm_inst.genblk1[8].csa.y ),
    .CLK(clknet_3_4__leaf_clk_i));
 sg13g2_dfrbpq_1 _183_ (.RESET_B(net25),
    .D(_013_),
    .Q(\spm_inst.genblk1[8].csa.sc ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _184_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[8].csa.hsum2 ),
    .Q(\spm_inst.genblk1[7].csa.y ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _185_ (.RESET_B(net23),
    .D(_012_),
    .Q(\spm_inst.genblk1[7].csa.sc ),
    .CLK(clknet_3_1__leaf_clk_i));
 sg13g2_dfrbpq_1 _186_ (.RESET_B(net22),
    .D(\spm_inst.genblk1[7].csa.hsum2 ),
    .Q(\spm_inst.genblk1[6].csa.y ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _187_ (.RESET_B(net22),
    .D(_011_),
    .Q(\spm_inst.genblk1[6].csa.sc ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _188_ (.RESET_B(net22),
    .D(\spm_inst.genblk1[6].csa.hsum2 ),
    .Q(\spm_inst.genblk1[5].csa.y ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _189_ (.RESET_B(net22),
    .D(_010_),
    .Q(\spm_inst.genblk1[5].csa.sc ),
    .CLK(clknet_3_2__leaf_clk_i));
 sg13g2_dfrbpq_1 _190_ (.RESET_B(net26),
    .D(\spm_inst.genblk1[5].csa.hsum2 ),
    .Q(\spm_inst.genblk1[4].csa.y ),
    .CLK(clknet_3_3__leaf_clk_i));
 sg13g2_dfrbpq_1 _191_ (.RESET_B(net25),
    .D(_009_),
    .Q(\spm_inst.genblk1[4].csa.sc ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _192_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[4].csa.hsum2 ),
    .Q(\spm_inst.genblk1[3].csa.y ),
    .CLK(clknet_3_6__leaf_clk_i));
 sg13g2_dfrbpq_1 _193_ (.RESET_B(net25),
    .D(_008_),
    .Q(\spm_inst.genblk1[3].csa.sc ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _194_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[3].csa.hsum2 ),
    .Q(\spm_inst.genblk1[2].csa.y ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _195_ (.RESET_B(net25),
    .D(_007_),
    .Q(\spm_inst.genblk1[2].csa.sc ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _196_ (.RESET_B(net25),
    .D(\spm_inst.genblk1[2].csa.hsum2 ),
    .Q(\spm_inst.genblk1[1].csa.y ),
    .CLK(clknet_3_7__leaf_clk_i));
 sg13g2_dfrbpq_1 _197_ (.RESET_B(net24),
    .D(_006_),
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
    .D(_000_),
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
