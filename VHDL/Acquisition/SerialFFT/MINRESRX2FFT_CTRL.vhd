
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MINRESRX2FFT_CTRL IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        enb                               :   IN    std_logic;
        din_1_re                          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        din_1_im                          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        validIn                           :   IN    std_logic;
        stgOut1_re                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        stgOut1_im                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        stgOut2_re                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        stgOut2_im                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        stgOut_vld                        :   IN    std_logic;
        syncReset                         :   IN    std_logic;
        dMemIn1_re                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemIn1_im                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemIn2_re                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        dMemIn2_im                        :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        wrEnb1                            :   OUT   std_logic;
        wrEnb2                            :   OUT   std_logic;
        wrEnb3                            :   OUT   std_logic;
        rdEnb1                            :   OUT   std_logic;
        rdEnb2                            :   OUT   std_logic;
        rdEnb3                            :   OUT   std_logic;
        dMemOut_vld                       :   OUT   std_logic;
        vldOut                            :   OUT   std_logic;
        stage                             :   OUT   std_logic_vector(3 DOWNTO 0);  -- ufix4
        rdy                               :   OUT   std_logic;
        initIC                            :   OUT   std_logic;
        unLoadPhase                       :   OUT   std_logic
        );
END MINRESRX2FFT_CTRL;


ARCHITECTURE rtl OF MINRESRX2FFT_CTRL IS

  -- Signals
  SIGNAL din_1_re_signed                  : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL din_1_im_signed                  : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL stgOut1_re_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL stgOut1_im_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL stgOut2_re_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL stgOut2_im_signed                : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTCtrl_rdyReg          : std_logic;
  SIGNAL minResRX2FFTCtrl_inSampleCnt     : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL minResRX2FFTCtrl_outSampleCnt    : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL minResRX2FFTCtrl_state           : unsigned(3 DOWNTO 0);  -- ufix4
  SIGNAL minResRX2FFTCtrl_stageReg        : unsigned(3 DOWNTO 0);  -- ufix4
  SIGNAL minResRX2FFTCtrl_procCnt         : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTCtrl_waitCnt         : unsigned(2 DOWNTO 0);  -- ufix3
  SIGNAL minResRX2FFTCtrl_wrEnb1_Reg      : std_logic;
  SIGNAL minResRX2FFTCtrl_wrEnb2_Reg      : std_logic;
  SIGNAL minResRX2FFTCtrl_wrEnb3_Reg      : std_logic;
  SIGNAL minResRX2FFTCtrl_rdEnb1_Reg      : std_logic;
  SIGNAL minResRX2FFTCtrl_rdEnb2_Reg      : std_logic;
  SIGNAL minResRX2FFTCtrl_rdEnb3_Reg      : std_logic;
  SIGNAL minResRX2FFTCtrl_dOut1Re_Reg     : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTCtrl_dOut2Re_Reg     : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTCtrl_dOut1Im_Reg     : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTCtrl_dOut2Im_Reg     : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTCtrl_xSample_re      : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTCtrl_xSample_im      : signed(31 DOWNTO 0);  -- sfix32
  SIGNAL minResRX2FFTCtrl_xSampleVld      : std_logic;
  SIGNAL minResRX2FFTCtrl_unLoadReg       : std_logic;
  SIGNAL minResRX2FFTCtrl_btfInVld_Reg    : std_logic;
  SIGNAL minResRX2FFTCtrl_vldOut_Reg      : std_logic;
  SIGNAL minResRX2FFTCtrl_initICReg       : std_logic;
  SIGNAL minResRX2FFTCtrl_memWait         : unsigned(1 DOWNTO 0);  -- ufix2
  SIGNAL minResRX2FFTCtrl_activeMem       : std_logic;
  SIGNAL minResRX2FFTCtrl_rdyReg_next     : std_logic;
  SIGNAL minResRX2FFTCtrl_inSampleCnt_next : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL minResRX2FFTCtrl_outSampleCnt_next : unsigned(14 DOWNTO 0);  -- ufix15
  SIGNAL minResRX2FFTCtrl_state_next      : unsigned(3 DOWNTO 0);  -- ufix4
  SIGNAL minResRX2FFTCtrl_stageReg_next   : unsigned(3 DOWNTO 0);  -- ufix4
  SIGNAL minResRX2FFTCtrl_procCnt_next    : unsigned(13 DOWNTO 0);  -- ufix14
  SIGNAL minResRX2FFTCtrl_waitCnt_next    : unsigned(2 DOWNTO 0);  -- ufix3
  SIGNAL minResRX2FFTCtrl_wrEnb1_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_wrEnb2_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_wrEnb3_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_rdEnb1_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_rdEnb2_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_rdEnb3_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_dOut1Re_Reg_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTCtrl_dOut2Re_Reg_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTCtrl_dOut1Im_Reg_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTCtrl_dOut2Im_Reg_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTCtrl_xSample_re_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTCtrl_xSample_im_next : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL minResRX2FFTCtrl_xSampleVld_next : std_logic;
  SIGNAL minResRX2FFTCtrl_unLoadReg_next  : std_logic;
  SIGNAL minResRX2FFTCtrl_btfInVld_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_vldOut_Reg_next : std_logic;
  SIGNAL minResRX2FFTCtrl_initICReg_next  : std_logic;
  SIGNAL minResRX2FFTCtrl_memWait_next    : unsigned(1 DOWNTO 0);  -- ufix2
  SIGNAL minResRX2FFTCtrl_activeMem_next  : std_logic;
  SIGNAL dMemIn1_re_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemIn1_im_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemIn2_re_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL dMemIn2_im_tmp                   : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL stage_tmp                        : unsigned(3 DOWNTO 0);  -- ufix4

BEGIN
  din_1_re_signed <= signed(din_1_re);

  din_1_im_signed <= signed(din_1_im);

  stgOut1_re_signed <= signed(stgOut1_re);

  stgOut1_im_signed <= signed(stgOut1_im);

  stgOut2_re_signed <= signed(stgOut2_re);

  stgOut2_im_signed <= signed(stgOut2_im);

  -- minResRX2FFTCtrl
  minResRX2FFTCtrl_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      minResRX2FFTCtrl_state <= to_unsigned(16#0#, 4);
      minResRX2FFTCtrl_rdyReg <= '1';
      minResRX2FFTCtrl_inSampleCnt <= to_unsigned(16#0000#, 15);
      minResRX2FFTCtrl_outSampleCnt <= to_unsigned(16#0000#, 15);
      minResRX2FFTCtrl_procCnt <= to_unsigned(16#0000#, 14);
      minResRX2FFTCtrl_waitCnt <= to_unsigned(16#0#, 3);
      minResRX2FFTCtrl_memWait <= to_unsigned(16#0#, 2);
      minResRX2FFTCtrl_wrEnb1_Reg <= '0';
      minResRX2FFTCtrl_wrEnb2_Reg <= '0';
      minResRX2FFTCtrl_wrEnb3_Reg <= '0';
      minResRX2FFTCtrl_stageReg <= to_unsigned(16#0#, 4);
      minResRX2FFTCtrl_dOut1Re_Reg <= to_signed(0, 32);
      minResRX2FFTCtrl_dOut2Re_Reg <= to_signed(0, 32);
      minResRX2FFTCtrl_dOut1Im_Reg <= to_signed(0, 32);
      minResRX2FFTCtrl_dOut2Im_Reg <= to_signed(0, 32);
      minResRX2FFTCtrl_rdEnb1_Reg <= '0';
      minResRX2FFTCtrl_rdEnb2_Reg <= '0';
      minResRX2FFTCtrl_rdEnb3_Reg <= '0';
      minResRX2FFTCtrl_xSample_re <= to_signed(0, 32);
      minResRX2FFTCtrl_xSample_im <= to_signed(0, 32);
      minResRX2FFTCtrl_xSampleVld <= '0';
      minResRX2FFTCtrl_vldOut_Reg <= '0';
      minResRX2FFTCtrl_btfInVld_Reg <= '0';
      minResRX2FFTCtrl_initICReg <= '0';
      minResRX2FFTCtrl_unLoadReg <= '0';
      minResRX2FFTCtrl_activeMem <= '0';
    ELSIF clk'EVENT AND clk = '1' THEN
      IF enb = '1' THEN
        IF syncReset = '1' THEN
          minResRX2FFTCtrl_state <= to_unsigned(16#0#, 4);
          minResRX2FFTCtrl_rdyReg <= '1';
          minResRX2FFTCtrl_inSampleCnt <= to_unsigned(16#0000#, 15);
          minResRX2FFTCtrl_outSampleCnt <= to_unsigned(16#0000#, 15);
          minResRX2FFTCtrl_procCnt <= to_unsigned(16#0000#, 14);
          minResRX2FFTCtrl_waitCnt <= to_unsigned(16#0#, 3);
          minResRX2FFTCtrl_memWait <= to_unsigned(16#0#, 2);
          minResRX2FFTCtrl_wrEnb1_Reg <= '0';
          minResRX2FFTCtrl_wrEnb2_Reg <= '0';
          minResRX2FFTCtrl_wrEnb3_Reg <= '0';
          minResRX2FFTCtrl_stageReg <= to_unsigned(16#0#, 4);
          minResRX2FFTCtrl_dOut1Re_Reg <= to_signed(0, 32);
          minResRX2FFTCtrl_dOut2Re_Reg <= to_signed(0, 32);
          minResRX2FFTCtrl_dOut1Im_Reg <= to_signed(0, 32);
          minResRX2FFTCtrl_dOut2Im_Reg <= to_signed(0, 32);
          minResRX2FFTCtrl_rdEnb1_Reg <= '0';
          minResRX2FFTCtrl_rdEnb2_Reg <= '0';
          minResRX2FFTCtrl_rdEnb3_Reg <= '0';
          minResRX2FFTCtrl_xSample_re <= to_signed(0, 32);
          minResRX2FFTCtrl_xSample_im <= to_signed(0, 32);
          minResRX2FFTCtrl_xSampleVld <= '0';
          minResRX2FFTCtrl_vldOut_Reg <= '0';
          minResRX2FFTCtrl_btfInVld_Reg <= '0';
          minResRX2FFTCtrl_initICReg <= '0';
          minResRX2FFTCtrl_unLoadReg <= '0';
          minResRX2FFTCtrl_activeMem <= '0';
        ELSE 
          minResRX2FFTCtrl_rdyReg <= minResRX2FFTCtrl_rdyReg_next;
          minResRX2FFTCtrl_inSampleCnt <= minResRX2FFTCtrl_inSampleCnt_next;
          minResRX2FFTCtrl_outSampleCnt <= minResRX2FFTCtrl_outSampleCnt_next;
          minResRX2FFTCtrl_state <= minResRX2FFTCtrl_state_next;
          minResRX2FFTCtrl_stageReg <= minResRX2FFTCtrl_stageReg_next;
          minResRX2FFTCtrl_procCnt <= minResRX2FFTCtrl_procCnt_next;
          minResRX2FFTCtrl_waitCnt <= minResRX2FFTCtrl_waitCnt_next;
          minResRX2FFTCtrl_wrEnb1_Reg <= minResRX2FFTCtrl_wrEnb1_Reg_next;
          minResRX2FFTCtrl_wrEnb2_Reg <= minResRX2FFTCtrl_wrEnb2_Reg_next;
          minResRX2FFTCtrl_wrEnb3_Reg <= minResRX2FFTCtrl_wrEnb3_Reg_next;
          minResRX2FFTCtrl_rdEnb1_Reg <= minResRX2FFTCtrl_rdEnb1_Reg_next;
          minResRX2FFTCtrl_rdEnb2_Reg <= minResRX2FFTCtrl_rdEnb2_Reg_next;
          minResRX2FFTCtrl_rdEnb3_Reg <= minResRX2FFTCtrl_rdEnb3_Reg_next;
          minResRX2FFTCtrl_dOut1Re_Reg <= minResRX2FFTCtrl_dOut1Re_Reg_next;
          minResRX2FFTCtrl_dOut2Re_Reg <= minResRX2FFTCtrl_dOut2Re_Reg_next;
          minResRX2FFTCtrl_dOut1Im_Reg <= minResRX2FFTCtrl_dOut1Im_Reg_next;
          minResRX2FFTCtrl_dOut2Im_Reg <= minResRX2FFTCtrl_dOut2Im_Reg_next;
          minResRX2FFTCtrl_xSample_re <= minResRX2FFTCtrl_xSample_re_next;
          minResRX2FFTCtrl_xSample_im <= minResRX2FFTCtrl_xSample_im_next;
          minResRX2FFTCtrl_xSampleVld <= minResRX2FFTCtrl_xSampleVld_next;
          minResRX2FFTCtrl_unLoadReg <= minResRX2FFTCtrl_unLoadReg_next;
          minResRX2FFTCtrl_btfInVld_Reg <= minResRX2FFTCtrl_btfInVld_Reg_next;
          minResRX2FFTCtrl_vldOut_Reg <= minResRX2FFTCtrl_vldOut_Reg_next;
          minResRX2FFTCtrl_initICReg <= minResRX2FFTCtrl_initICReg_next;
          minResRX2FFTCtrl_memWait <= minResRX2FFTCtrl_memWait_next;
          minResRX2FFTCtrl_activeMem <= minResRX2FFTCtrl_activeMem_next;
        END IF;
      END IF;
    END IF;
  END PROCESS minResRX2FFTCtrl_process;

  minResRX2FFTCtrl_output : PROCESS (din_1_im_signed, din_1_re_signed, minResRX2FFTCtrl_activeMem,
       minResRX2FFTCtrl_btfInVld_Reg, minResRX2FFTCtrl_dOut1Im_Reg,
       minResRX2FFTCtrl_dOut1Re_Reg, minResRX2FFTCtrl_dOut2Im_Reg,
       minResRX2FFTCtrl_dOut2Re_Reg, minResRX2FFTCtrl_inSampleCnt,
       minResRX2FFTCtrl_initICReg, minResRX2FFTCtrl_memWait,
       minResRX2FFTCtrl_outSampleCnt, minResRX2FFTCtrl_procCnt,
       minResRX2FFTCtrl_rdEnb1_Reg, minResRX2FFTCtrl_rdEnb2_Reg,
       minResRX2FFTCtrl_rdEnb3_Reg, minResRX2FFTCtrl_rdyReg,
       minResRX2FFTCtrl_stageReg, minResRX2FFTCtrl_state,
       minResRX2FFTCtrl_unLoadReg, minResRX2FFTCtrl_vldOut_Reg,
       minResRX2FFTCtrl_waitCnt, minResRX2FFTCtrl_wrEnb1_Reg,
       minResRX2FFTCtrl_wrEnb2_Reg, minResRX2FFTCtrl_wrEnb3_Reg,
       minResRX2FFTCtrl_xSampleVld, minResRX2FFTCtrl_xSample_im,
       minResRX2FFTCtrl_xSample_re, stgOut1_im_signed, stgOut1_re_signed,
       stgOut2_im_signed, stgOut2_re_signed, stgOut_vld, validIn)
    VARIABLE stageLSB : std_logic;
    VARIABLE vldOut_Reg : std_logic;
  BEGIN
    vldOut_Reg := '0';
    minResRX2FFTCtrl_inSampleCnt_next <= minResRX2FFTCtrl_inSampleCnt;
    minResRX2FFTCtrl_rdEnb2_Reg_next <= minResRX2FFTCtrl_rdEnb2_Reg;
    minResRX2FFTCtrl_rdyReg_next <= minResRX2FFTCtrl_rdyReg;
    minResRX2FFTCtrl_outSampleCnt_next <= minResRX2FFTCtrl_outSampleCnt;
    minResRX2FFTCtrl_state_next <= minResRX2FFTCtrl_state;
    minResRX2FFTCtrl_stageReg_next <= minResRX2FFTCtrl_stageReg;
    minResRX2FFTCtrl_procCnt_next <= minResRX2FFTCtrl_procCnt;
    minResRX2FFTCtrl_waitCnt_next <= minResRX2FFTCtrl_waitCnt;
    minResRX2FFTCtrl_wrEnb1_Reg_next <= minResRX2FFTCtrl_wrEnb1_Reg;
    minResRX2FFTCtrl_wrEnb2_Reg_next <= minResRX2FFTCtrl_wrEnb2_Reg;
    minResRX2FFTCtrl_wrEnb3_Reg_next <= minResRX2FFTCtrl_wrEnb3_Reg;
    minResRX2FFTCtrl_rdEnb1_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
    minResRX2FFTCtrl_rdEnb3_Reg_next <= minResRX2FFTCtrl_rdEnb3_Reg;
    minResRX2FFTCtrl_dOut1Re_Reg_next <= minResRX2FFTCtrl_dOut1Re_Reg;
    minResRX2FFTCtrl_dOut2Re_Reg_next <= minResRX2FFTCtrl_dOut2Re_Reg;
    minResRX2FFTCtrl_dOut1Im_Reg_next <= minResRX2FFTCtrl_dOut1Im_Reg;
    minResRX2FFTCtrl_dOut2Im_Reg_next <= minResRX2FFTCtrl_dOut2Im_Reg;
    minResRX2FFTCtrl_xSample_re_next <= minResRX2FFTCtrl_xSample_re;
    minResRX2FFTCtrl_xSample_im_next <= minResRX2FFTCtrl_xSample_im;
    minResRX2FFTCtrl_xSampleVld_next <= minResRX2FFTCtrl_xSampleVld;
    minResRX2FFTCtrl_unLoadReg_next <= minResRX2FFTCtrl_unLoadReg;
    minResRX2FFTCtrl_btfInVld_Reg_next <= minResRX2FFTCtrl_btfInVld_Reg;
    minResRX2FFTCtrl_vldOut_Reg_next <= minResRX2FFTCtrl_vldOut_Reg;
    minResRX2FFTCtrl_initICReg_next <= minResRX2FFTCtrl_initICReg;
    minResRX2FFTCtrl_memWait_next <= minResRX2FFTCtrl_memWait;
    minResRX2FFTCtrl_activeMem_next <= minResRX2FFTCtrl_activeMem;
    IF minResRX2FFTCtrl_stageReg(0) /= '0' THEN 
      stageLSB := '1';
    ELSE 
      stageLSB := '0';
    END IF;
    CASE minResRX2FFTCtrl_state IS
      WHEN "0000" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#0#, 4);
        minResRX2FFTCtrl_rdyReg_next <= '1';
        minResRX2FFTCtrl_stageReg_next <= to_unsigned(16#0#, 4);
        minResRX2FFTCtrl_inSampleCnt_next <= to_unsigned(16#0000#, 15);
        minResRX2FFTCtrl_outSampleCnt_next <= to_unsigned(16#0000#, 15);
        minResRX2FFTCtrl_waitCnt_next <= to_unsigned(16#0#, 3);
        minResRX2FFTCtrl_memWait_next <= to_unsigned(16#0#, 2);
        minResRX2FFTCtrl_procCnt_next <= to_unsigned(16#0000#, 14);
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_dOut2Re_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_dOut1Im_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_dOut2Im_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_xSample_re_next <= to_signed(0, 32);
        minResRX2FFTCtrl_xSample_im_next <= to_signed(0, 32);
        minResRX2FFTCtrl_xSampleVld_next <= '0';
        minResRX2FFTCtrl_vldOut_Reg_next <= '0';
        minResRX2FFTCtrl_btfInVld_Reg_next <= '0';
        minResRX2FFTCtrl_unLoadReg_next <= '0';
        minResRX2FFTCtrl_activeMem_next <= '0';
        IF validIn = '1' THEN 
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_dOut1Re_Reg_next <= din_1_re_signed;
          minResRX2FFTCtrl_dOut1Im_Reg_next <= din_1_im_signed;
          minResRX2FFTCtrl_inSampleCnt_next <= to_unsigned(16#0001#, 15);
          minResRX2FFTCtrl_initICReg_next <= '1';
          minResRX2FFTCtrl_state_next <= to_unsigned(16#1#, 4);
        END IF;
      WHEN "0001" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#1#, 4);
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= din_1_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= din_1_im_signed;
        minResRX2FFTCtrl_initICReg_next <= '0';
        IF validIn = '1' THEN 
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          IF minResRX2FFTCtrl_inSampleCnt = to_unsigned(16#3FFF#, 15) THEN 
            minResRX2FFTCtrl_state_next <= to_unsigned(16#2#, 4);
            minResRX2FFTCtrl_stageReg_next <= to_unsigned(16#0#, 4);
            minResRX2FFTCtrl_inSampleCnt_next <= minResRX2FFTCtrl_inSampleCnt + to_unsigned(16#0001#, 15);
          ELSE 
            minResRX2FFTCtrl_inSampleCnt_next <= minResRX2FFTCtrl_inSampleCnt + to_unsigned(16#0001#, 15);
          END IF;
        END IF;
        minResRX2FFTCtrl_vldOut_Reg_next <= (minResRX2FFTCtrl_rdEnb1_Reg OR minResRX2FFTCtrl_rdEnb2_Reg) OR minResRX2FFTCtrl_rdEnb3_Reg;
        minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
        IF minResRX2FFTCtrl_outSampleCnt > to_unsigned(16#3FFF#, 15) THEN 
          minResRX2FFTCtrl_unLoadReg_next <= '1';
          minResRX2FFTCtrl_rdEnb2_Reg_next <=  NOT minResRX2FFTCtrl_activeMem;
          minResRX2FFTCtrl_rdEnb3_Reg_next <= minResRX2FFTCtrl_activeMem;
          minResRX2FFTCtrl_outSampleCnt_next <= minResRX2FFTCtrl_outSampleCnt + to_unsigned(16#0001#, 15);
        ELSE 
          minResRX2FFTCtrl_unLoadReg_next <= '0';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
          minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
        END IF;
      WHEN "0010" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#2#, 4);
        minResRX2FFTCtrl_rdyReg_next <= '1';
        minResRX2FFTCtrl_unLoadReg_next <= '0';
        minResRX2FFTCtrl_btfInVld_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
        minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_initICReg_next <= '0';
        IF validIn = '1' THEN 
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
          IF minResRX2FFTCtrl_inSampleCnt = to_unsigned(16#7FFF#, 15) THEN 
            minResRX2FFTCtrl_rdyReg_next <= '0';
            minResRX2FFTCtrl_state_next <= to_unsigned(16#3#, 4);
          END IF;
          minResRX2FFTCtrl_inSampleCnt_next <= minResRX2FFTCtrl_inSampleCnt + to_unsigned(16#0001#, 15);
        END IF;
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= stgOut1_re_signed;
        minResRX2FFTCtrl_dOut2Re_Reg_next <= stgOut2_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= stgOut1_im_signed;
        minResRX2FFTCtrl_dOut2Im_Reg_next <= stgOut2_im_signed;
        IF stgOut_vld = '1' THEN 
          minResRX2FFTCtrl_procCnt_next <= minResRX2FFTCtrl_procCnt + to_unsigned(16#0001#, 14);
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_wrEnb2_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_wrEnb3_Reg_next <= stageLSB;
        END IF;
        vldOut_Reg := minResRX2FFTCtrl_rdEnb3_Reg;
        minResRX2FFTCtrl_vldOut_Reg_next <= vldOut_Reg;
        IF minResRX2FFTCtrl_outSampleCnt > to_unsigned(16#3FFF#, 15) THEN 
          minResRX2FFTCtrl_rdEnb2_Reg_next <=  NOT minResRX2FFTCtrl_activeMem;
          minResRX2FFTCtrl_rdEnb3_Reg_next <= minResRX2FFTCtrl_activeMem;
          minResRX2FFTCtrl_outSampleCnt_next <= minResRX2FFTCtrl_outSampleCnt + to_unsigned(16#0001#, 15);
        ELSE 
          minResRX2FFTCtrl_vldOut_Reg_next <= '0';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
          minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
          minResRX2FFTCtrl_activeMem_next <= '0';
        END IF;
      WHEN "0011" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#3#, 4);
        minResRX2FFTCtrl_unLoadReg_next <= '0';
        minResRX2FFTCtrl_btfInVld_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
        minResRX2FFTCtrl_vldOut_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
        IF (validIn AND ( NOT minResRX2FFTCtrl_xSampleVld)) = '1' THEN 
          minResRX2FFTCtrl_xSample_re_next <= din_1_re_signed;
          minResRX2FFTCtrl_xSample_im_next <= din_1_im_signed;
          minResRX2FFTCtrl_xSampleVld_next <= '1';
        END IF;
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= stgOut1_re_signed;
        minResRX2FFTCtrl_dOut2Re_Reg_next <= stgOut2_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= stgOut1_im_signed;
        minResRX2FFTCtrl_dOut2Im_Reg_next <= stgOut2_im_signed;
        IF stgOut_vld = '1' THEN 
          IF minResRX2FFTCtrl_procCnt = to_unsigned(16#3FFF#, 14) THEN 
            minResRX2FFTCtrl_state_next <= to_unsigned(16#6#, 4);
          END IF;
          minResRX2FFTCtrl_procCnt_next <= minResRX2FFTCtrl_procCnt + to_unsigned(16#0001#, 14);
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_wrEnb2_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_wrEnb3_Reg_next <= stageLSB;
        END IF;
      WHEN "0100" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#4#, 4);
        minResRX2FFTCtrl_btfInVld_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
        minResRX2FFTCtrl_initICReg_next <= '0';
        IF minResRX2FFTCtrl_inSampleCnt = to_unsigned(16#7FFE#, 15) THEN 
          minResRX2FFTCtrl_state_next <= to_unsigned(16#5#, 4);
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= stageLSB;
          minResRX2FFTCtrl_rdEnb3_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_inSampleCnt_next <= to_unsigned(16#0000#, 15);
        ELSE 
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= stageLSB;
          minResRX2FFTCtrl_rdEnb3_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_inSampleCnt_next <= minResRX2FFTCtrl_inSampleCnt + to_unsigned(16#0002#, 15);
        END IF;
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= stgOut1_re_signed;
        minResRX2FFTCtrl_dOut2Re_Reg_next <= stgOut2_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= stgOut1_im_signed;
        minResRX2FFTCtrl_dOut2Im_Reg_next <= stgOut2_im_signed;
        IF stgOut_vld = '1' THEN 
          minResRX2FFTCtrl_procCnt_next <= minResRX2FFTCtrl_procCnt + to_unsigned(16#0001#, 14);
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_wrEnb2_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_wrEnb3_Reg_next <= stageLSB;
        END IF;
      WHEN "0101" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#5#, 4);
        minResRX2FFTCtrl_btfInVld_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
        minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= stgOut1_re_signed;
        minResRX2FFTCtrl_dOut2Re_Reg_next <= stgOut2_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= stgOut1_im_signed;
        minResRX2FFTCtrl_dOut2Im_Reg_next <= stgOut2_im_signed;
        IF stgOut_vld = '1' THEN 
          IF minResRX2FFTCtrl_procCnt = to_unsigned(16#3FFF#, 14) THEN 
            minResRX2FFTCtrl_state_next <= to_unsigned(16#6#, 4);
          END IF;
          minResRX2FFTCtrl_procCnt_next <= minResRX2FFTCtrl_procCnt + to_unsigned(16#0001#, 14);
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_wrEnb2_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_wrEnb3_Reg_next <= stageLSB;
        END IF;
      WHEN "0110" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#6#, 4);
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= stgOut1_re_signed;
        minResRX2FFTCtrl_dOut2Re_Reg_next <= stgOut2_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= stgOut1_im_signed;
        minResRX2FFTCtrl_dOut2Im_Reg_next <= stgOut2_im_signed;
        IF minResRX2FFTCtrl_memWait = to_unsigned(16#2#, 2) THEN 
          IF minResRX2FFTCtrl_stageReg = to_unsigned(16#D#, 4) THEN 
            minResRX2FFTCtrl_state_next <= to_unsigned(16#7#, 4);
          ELSE 
            minResRX2FFTCtrl_state_next <= to_unsigned(16#4#, 4);
          END IF;
          minResRX2FFTCtrl_initICReg_next <= '1';
          minResRX2FFTCtrl_stageReg_next <= minResRX2FFTCtrl_stageReg + to_unsigned(16#1#, 4);
          minResRX2FFTCtrl_memWait_next <= to_unsigned(16#0#, 2);
        ELSE 
          minResRX2FFTCtrl_memWait_next <= minResRX2FFTCtrl_memWait + to_unsigned(16#1#, 2);
        END IF;
      WHEN "0111" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#7#, 4);
        minResRX2FFTCtrl_btfInVld_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
        minResRX2FFTCtrl_initICReg_next <= '0';
        IF minResRX2FFTCtrl_inSampleCnt = to_unsigned(16#7FFE#, 15) THEN 
          minResRX2FFTCtrl_state_next <= to_unsigned(16#8#, 4);
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= stageLSB;
          minResRX2FFTCtrl_rdEnb3_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_inSampleCnt_next <= to_unsigned(16#0000#, 15);
        ELSE 
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= stageLSB;
          minResRX2FFTCtrl_rdEnb3_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_inSampleCnt_next <= minResRX2FFTCtrl_inSampleCnt + to_unsigned(16#0002#, 15);
        END IF;
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= stgOut1_re_signed;
        minResRX2FFTCtrl_dOut2Re_Reg_next <= stgOut2_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= stgOut1_im_signed;
        minResRX2FFTCtrl_dOut2Im_Reg_next <= stgOut2_im_signed;
        IF stgOut_vld = '1' THEN 
          minResRX2FFTCtrl_procCnt_next <= minResRX2FFTCtrl_procCnt + to_unsigned(16#0001#, 14);
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_wrEnb2_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_wrEnb3_Reg_next <= stageLSB;
        END IF;
      WHEN "1000" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#8#, 4);
        minResRX2FFTCtrl_btfInVld_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
        minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= stgOut1_re_signed;
        minResRX2FFTCtrl_dOut2Re_Reg_next <= stgOut2_re_signed;
        minResRX2FFTCtrl_dOut1Im_Reg_next <= stgOut1_im_signed;
        minResRX2FFTCtrl_dOut2Im_Reg_next <= stgOut2_im_signed;
        IF stgOut_vld = '1' THEN 
          IF minResRX2FFTCtrl_procCnt = to_unsigned(16#3FFF#, 14) THEN 
            minResRX2FFTCtrl_state_next <= to_unsigned(16#A#, 4);
            minResRX2FFTCtrl_unLoadReg_next <= '1';
            minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
            minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
            minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
            minResRX2FFTCtrl_vldOut_Reg_next <= '0';
            minResRX2FFTCtrl_activeMem_next <= stageLSB;
            minResRX2FFTCtrl_outSampleCnt_next <= minResRX2FFTCtrl_outSampleCnt + to_unsigned(16#0001#, 15);
          END IF;
          minResRX2FFTCtrl_procCnt_next <= minResRX2FFTCtrl_procCnt + to_unsigned(16#0001#, 14);
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_wrEnb2_Reg_next <=  NOT stageLSB;
          minResRX2FFTCtrl_wrEnb3_Reg_next <= stageLSB;
        END IF;
      WHEN "1001" =>
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        IF minResRX2FFTCtrl_waitCnt = to_unsigned(16#3#, 3) THEN 
          minResRX2FFTCtrl_state_next <= to_unsigned(16#A#, 4);
          minResRX2FFTCtrl_unLoadReg_next <= '1';
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
          minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
          minResRX2FFTCtrl_vldOut_Reg_next <= '0';
          minResRX2FFTCtrl_activeMem_next <= stageLSB;
          minResRX2FFTCtrl_outSampleCnt_next <= minResRX2FFTCtrl_outSampleCnt + to_unsigned(16#0001#, 15);
          minResRX2FFTCtrl_waitCnt_next <= to_unsigned(16#0#, 3);
        ELSE 
          minResRX2FFTCtrl_waitCnt_next <= minResRX2FFTCtrl_waitCnt + to_unsigned(16#1#, 3);
        END IF;
      WHEN "1010" =>
        minResRX2FFTCtrl_state_next <= to_unsigned(16#A#, 4);
        minResRX2FFTCtrl_btfInVld_Reg_next <= '0';
        minResRX2FFTCtrl_unLoadReg_next <= '1';
        minResRX2FFTCtrl_vldOut_Reg_next <= minResRX2FFTCtrl_rdEnb1_Reg;
        IF minResRX2FFTCtrl_outSampleCnt < to_unsigned(16#4000#, 15) THEN 
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '1';
          minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
          minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
        ELSE 
          minResRX2FFTCtrl_rdyReg_next <= '1';
          minResRX2FFTCtrl_stageReg_next <= to_unsigned(16#0#, 4);
          minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
          minResRX2FFTCtrl_rdEnb2_Reg_next <=  NOT minResRX2FFTCtrl_activeMem;
          minResRX2FFTCtrl_rdEnb3_Reg_next <= minResRX2FFTCtrl_activeMem;
          minResRX2FFTCtrl_state_next <= to_unsigned(16#1#, 4);
          minResRX2FFTCtrl_initICReg_next <= '1';
        END IF;
        minResRX2FFTCtrl_outSampleCnt_next <= minResRX2FFTCtrl_outSampleCnt + to_unsigned(16#0001#, 15);
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        IF minResRX2FFTCtrl_xSampleVld = '1' THEN 
          minResRX2FFTCtrl_dOut1Re_Reg_next <= minResRX2FFTCtrl_xSample_re;
          minResRX2FFTCtrl_dOut1Im_Reg_next <= minResRX2FFTCtrl_xSample_im;
          minResRX2FFTCtrl_xSampleVld_next <= '0';
          minResRX2FFTCtrl_inSampleCnt_next <= minResRX2FFTCtrl_inSampleCnt + to_unsigned(16#0001#, 15);
          minResRX2FFTCtrl_wrEnb1_Reg_next <= '1';
        END IF;
      WHEN OTHERS => 
        minResRX2FFTCtrl_state_next <= to_unsigned(16#0#, 4);
        minResRX2FFTCtrl_rdyReg_next <= '1';
        minResRX2FFTCtrl_stageReg_next <= to_unsigned(16#0#, 4);
        minResRX2FFTCtrl_inSampleCnt_next <= to_unsigned(16#0000#, 15);
        minResRX2FFTCtrl_procCnt_next <= to_unsigned(16#0000#, 14);
        minResRX2FFTCtrl_waitCnt_next <= to_unsigned(16#0#, 3);
        minResRX2FFTCtrl_wrEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_wrEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb1_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb2_Reg_next <= '0';
        minResRX2FFTCtrl_rdEnb3_Reg_next <= '0';
        minResRX2FFTCtrl_dOut1Re_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_dOut2Re_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_dOut1Im_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_dOut2Im_Reg_next <= to_signed(0, 32);
        minResRX2FFTCtrl_xSample_re_next <= to_signed(0, 32);
        minResRX2FFTCtrl_xSample_im_next <= to_signed(0, 32);
        minResRX2FFTCtrl_xSampleVld_next <= '0';
        minResRX2FFTCtrl_btfInVld_Reg_next <= '0';
        minResRX2FFTCtrl_unLoadReg_next <= '0';
    END CASE;
    dMemIn1_re_tmp <= minResRX2FFTCtrl_dOut1Re_Reg;
    dMemIn1_im_tmp <= minResRX2FFTCtrl_dOut1Im_Reg;
    dMemIn2_re_tmp <= minResRX2FFTCtrl_dOut2Re_Reg;
    dMemIn2_im_tmp <= minResRX2FFTCtrl_dOut2Im_Reg;
    wrEnb1 <= minResRX2FFTCtrl_wrEnb1_Reg;
    wrEnb2 <= minResRX2FFTCtrl_wrEnb2_Reg;
    wrEnb3 <= minResRX2FFTCtrl_wrEnb3_Reg;
    rdEnb1 <= minResRX2FFTCtrl_rdEnb1_Reg;
    rdEnb2 <= minResRX2FFTCtrl_rdEnb2_Reg;
    rdEnb3 <= minResRX2FFTCtrl_rdEnb3_Reg;
    dMemOut_vld <= minResRX2FFTCtrl_btfInVld_Reg;
    vldOut <= minResRX2FFTCtrl_vldOut_Reg;
    stage_tmp <= minResRX2FFTCtrl_stageReg;
    rdy <= minResRX2FFTCtrl_rdyReg;
    initIC <= minResRX2FFTCtrl_initICReg;
    unLoadPhase <= minResRX2FFTCtrl_unLoadReg;
  END PROCESS minResRX2FFTCtrl_output;


  dMemIn1_re <= std_logic_vector(dMemIn1_re_tmp);

  dMemIn1_im <= std_logic_vector(dMemIn1_im_tmp);

  dMemIn2_re <= std_logic_vector(dMemIn2_re_tmp);

  dMemIn2_im <= std_logic_vector(dMemIn2_im_tmp);

  stage <= std_logic_vector(stage_tmp);

END rtl;

