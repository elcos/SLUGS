% =========================================================================
% The following script parses the telemetry data generated by UCSCAP
% and produces a Matrix with the resulting data. If asked to, it also plots
% all the values.
% It returns Five matrices. 
% 1.- Position and Attitude (phi theta psi p q r x y z vx vy vz)
% 2.- GPS Data (lat lon height COG SOG yr mo dy hr min sec hdop sats)
% 3.- Bias (axb ayb azb gxb gyb gzb)
% 4.- Raw data (Gyros, Accels and Mags)
% 5.- Air Data and Diag
% 6.- Time vector
%
% Code by: Mariano Lizarraga 
% Last Revision: Nov 2008
%==========================================================================
%% Function header
function [M PosAtt GPS Bias Raw AirDiag time] = parseTelemetry (filename, plotData, validateGPS, figct)
% clear the screen
clc;
% parse the comma separated value file
%M_ld = load(filename);
%M = M_ld.M;
M = filename;

% If plotting only raw make this 15, otherwise make it 0;
onlyRaw = 0;

%% Index Definitions

% Attitude
% ========
timeStampIdx    = 1;
attRollIdx      = 2;
attPitchIdx     = 3;
attYawIdx       = 4;
attPIdx         = 5;
attQIdx         = 6;
attRIdx         = 7;

% Position
% ========
posXIdx         = 8;
posYIdx         = 9;
posZIdx         = 10;
posVxIdx        = 11;
posVyIdx        = 12;
posVzIdx        = 13;

% GPS
% ===
gpsYrIdx        = 14;
gpsMoIdx        = 15;
gpsDyIdx        = 16;
gpsHrIdx        = 17;
gpsMnIdx        = 18;
gpsScIdx        = 19;
gpsLatIdx       = 20;
gpsLonIdx       = 21;
gpsHeiIdx       = 22;
gpsCogIdx       = 23;
gpsSogIdx       = 24;
gpsHdoIdx       = 25;
gpsFixIdx       = 26;
gpsSatIdx       = 27;
gpsNewIdx       = 28;

% Raw Data
% ========
rawGxIdx        = 29 - onlyRaw;
rawGyIdx        = 30 - onlyRaw;
rawGzIdx        = 31 - onlyRaw;
rawAxIdx        = 32 - onlyRaw;
rawAyIdx        = 33 - onlyRaw;
rawAzIdx        = 34 - onlyRaw;
rawMxIdx        = 35 - onlyRaw;
rawMyIdx        = 36 - onlyRaw;
rawMzIdx        = 37 - onlyRaw;
rawBarIdx       = 38 - onlyRaw;
rawPitIdx       = 39 - onlyRaw;
rawPwrIdx       = 40 - onlyRaw;
rawTheIdx       = 41 - onlyRaw;

% Bias
% ====
biaAxIdx        = 42;
biaAyIdx        = 43;
biaAzIdx        = 44;
biaGxIdx        = 45;
biaGyIdx        = 46;
biaGzIdx        = 47;

% Air data and Diagnostics
% ==========================
airDynIdx       = 48;
airStaIdx       = 49;
airTemIdx       = 50;
diaFl1Idx       = 51;
diaFl2Idx       = 52;
diaFl3Idx       = 53;
diaSh1Idx       = 54;
diaSh2Idx       = 55;
diaSh3Idx       = 56;

% Load message
% ==============
loaSenIdx       = 57;
loaCtrIdx       = 58;
loaVolIdx       = 59;

% Pilot Console Message 
% ======================
pilDtIdx        = 60;
pilDlaIdx       = 61;
pilFaiIdx       = 62;
pilDrIdx        = 63;
pilDeIdx        = 64;

% PWM Messages (Sent to control surfaces)
% =========================================
pwmDtIdx        = 65;
pwmDlaIdx       = 66;
pwmDraIdx       = 67;
pwmDrIdx        = 68;
pwmDleIdx       = 69;
pwmDreIdx       = 70;
pwmDlfIdx       = 71;
pwmDrfIdx       = 72;
pwmDa1Idx       = 73;
pwmDa2Idx       = 74;

% Aircraft Status
% =================
apsCtyIdx       = 75;
apsBeaIdx       = 76;
apsHilIdx       = 77;

% Passthroughs
% ============
apsPthIdx       = 78;
apsPlaIdx       = 79;
apsPraIdx       = 80;
apsPruIdx       = 81;
apsPleIdx       = 82;
apsPreIdx       = 83;
apsPlfIdx       = 84;
apsPrfIdx       = 85;

% Ground Station Commands
% =========================
comHeiIdx       = 86;
comAirIdx       = 87;
comPhiIdx       = 88;
comTheIdx       = 89;
comPsiIdx       = 90;
comPIdx         = 91;
comQIdx         = 92;
comRIdx         = 93;
comCwpIdx       = 94;
comNwpIdx       = 95;

% Navigation Data
% ===============
navUmIdx        = 96;
navThcIdx       = 97;
navPdcIdx       = 98;
navPhcIdx       = 99;
navRhpIdx       = 100;
navTruIdx       = 101;
navD2gIdx       = 102;
navFwpIdx       = 103;
navTwpIdx       = 104;

% Sensors in Units
% ================
senAxIdx        = 105;
senAyIdx        = 106;
senAzIdx        = 107;
senMxIdx        = 108;
senMyIdx        = 109;
senMzIdx        = 110;

% Log Mesasges
% ============
logFl1idx       = 111;
logFl2idx       = 112;
logFl3idx       = 113;
logFl4idx       = 114;
logFl5idx       = 115;
logFl6idx       = 116;


%% if we need to validate GPS
idxIni = 1;
idxEnd = size(M,1);

if (validateGPS == 1)
    while (M(idxIni,gpsSatIdx) < 3)
        idxIni = idxIni +1;
    end
end;

%% Assemple the return matrices
%PosAtt GPS Bias Raw AirDiag Time

% Capture the Time counter to plot 
time_plot   = (M(idxIni:idxEnd,timeStampIdx));

% Produce the Time vector
time = 0:0.01:(size(M(idxIni:idxEnd,1))*.01 - 0.01);
    
autoIdx = find(M(idxIni:idxEnd,64)< 6000);

%time   = M(idxIni:idxEnd,timeStampIdx);

phi = M(idxIni:idxEnd,attRollIdx);
the = M(idxIni:idxEnd,attPitchIdx);
psi = M(idxIni:idxEnd,attYawIdx);
p   = M(idxIni:idxEnd,attPIdx);
q   = M(idxIni:idxEnd,attQIdx);
r   = M(idxIni:idxEnd,attRIdx);

x   = M(idxIni:idxEnd,posXIdx);
y   = M(idxIni:idxEnd,posYIdx);
z   = M(idxIni:idxEnd,posZIdx);
vx  = M(idxIni:idxEnd,posVxIdx);
vy  = M(idxIni:idxEnd,posVyIdx);
vz  = M(idxIni:idxEnd,posVzIdx);

rgx =  M(idxIni:idxEnd,rawGxIdx);
rgy =  M(idxIni:idxEnd,rawGyIdx);
rgz =  M(idxIni:idxEnd,rawGzIdx);

rax =  M(idxIni:idxEnd,rawAxIdx);
ray =  M(idxIni:idxEnd,rawAyIdx);
raz =  M(idxIni:idxEnd,rawAzIdx);

rmx =  M(idxIni:idxEnd,rawMxIdx);
rmy =  M(idxIni:idxEnd,rawMyIdx);
rmz =  M(idxIni:idxEnd,rawMzIdx);

rba = M(idxIni:idxEnd,rawBarIdx);
rpi = M(idxIni:idxEnd,rawPitIdx);
rpo = M(idxIni:idxEnd,rawPwrIdx);
rth = M(idxIni:idxEnd,rawTheIdx);

if onlyRaw == 0
    lat =  M(idxIni:idxEnd,gpsLatIdx);
    lon =  M(idxIni:idxEnd,gpsLonIdx);
    hei =  M(idxIni:idxEnd,gpsHeiIdx);
    cog =  M(idxIni:idxEnd,gpsCogIdx);
    sog =  M(idxIni:idxEnd,gpsSogIdx)/100;
    sec =  M(idxIni:idxEnd,gpsScIdx);
    sat =  M(idxIni:idxEnd,gpsSatIdx);

    bax =  M(idxIni:idxEnd,biaAxIdx);
    bay =  M(idxIni:idxEnd,biaAyIdx);
    baz =  M(idxIni:idxEnd,biaAzIdx);

    bgx =  M(idxIni:idxEnd,biaGxIdx);
    bgy =  M(idxIni:idxEnd,biaGyIdx);
    bgz =  M(idxIni:idxEnd,biaGzIdx);

    dyn = M(idxIni:idxEnd,airDynIdx);
    sta = M(idxIni:idxEnd,airStaIdx);
    oat = M(idxIni:idxEnd,airTemIdx);

    fl1 = M(idxIni:idxEnd,diaFl1Idx);
    fl2 = M(idxIni:idxEnd,diaFl2Idx);
    fl3 = M(idxIni:idxEnd,diaFl3Idx);

    sh1 = M(idxIni:idxEnd,diaSh1Idx);
    sh2 = M(idxIni:idxEnd,diaSh2Idx);
    sh3 = M(idxIni:idxEnd,diaSh3Idx);
    
    hc = M(idxIni:idxEnd,comHeiIdx);
    um = M(idxIni:idxEnd,navUmIdx);
    uc = M(idxIni:idxEnd,comAirIdx);
    rhp = M(idxIni:idxEnd,navRhpIdx);
    phi_c = M(idxIni:idxEnd,navPhcIdx);
    the_c = M(idxIni:idxEnd,navThcIdx);
end

%%
if plotData == 1
     
    % Plot the time count 
    figure (figct)
        plot(time, time_plot);
        title('16-bit Tick Counter');
        ylabel('Ticks');
        xlabel('Time (s)');
    
    eval(['print -depsc  '  num2str(figct)]);
    figct = figct + 1;
     
    % plot the rates and euler angles
    figure(figct)
    subplot(2,3,1)
        plot(time, p);
        title('Roll Rate p');
        ylabel('Radians/s');
    subplot(2,3,2)
        plot(time, q);
        title('Pitch Rate q');        
    subplot(2,3,3)
        plot(time, r);
        title('Yaw Rate r');        
    subplot(2,3,4)
        plot(time, phi);
        title('Roll \phi');        
        xlabel('Time (s)');
        ylabel ('Radians');
    subplot(2,3,5)
        plot(time, the);
        title('Pitch \theta');        
        xlabel('Time (s)');
    subplot(2,3,6)
        plot(time, psi);
        title('Yaw \psi');        
        xlabel('Time (s)');
    
    eval(['print -depsc  '  num2str(figct)]);
    figct = figct + 1;
        
            
    % plot the raw accelerometer
    figure(figct)
    subplot(3,1,1)
        plot(time, rax);
        title('Raw Acceleration in X');        
    subplot(3,1,2)
        plot(time, ray);
        title('Raw Acceleration in Y');                
    subplot(3,1,3)
        plot(time, raz);
        title('Raw Acceleration in Z');                
        xlabel('Time (s)');
    
    eval(['print -depsc  '  num2str(figct)]);
    figct = figct + 1;

        
    % plot the raw gyro
    figure(figct)
    subplot(3,1,1)
        plot(time, rgx);
        title('Raw Gyro X');        
    subplot(3,1,2)
        plot(time, rgy);
        title('Raw Gyro Y');                
    subplot(3,1,3)
        plot(time, rgz);
        title('Raw Gyro z');                
        xlabel('Time (s)');
        
    eval(['print -depsc  '  num2str(figct)]);
    figct = figct + 1;

    
% plot the raw mags
    figure(figct)
    subplot(3,1,1)
        plot(time, rmx);
        title('Raw Mag X');        
    subplot(3,1,2)
        plot(time, rmy);
        title('Raw Mag Y');                
    subplot(3,1,3)
        plot(time, rmz);
        title('Raw Mag z');                
        xlabel('Time (s)');
        
    eval(['print -depsc  '  num2str(figct)]);
    figct = figct + 1;

% plot the raw extra sensors
    figure(figct)
    subplot(4,1,1)
        plot(time, rba);
        title('Raw Barometer');        
    subplot(4,1,2)
        plot(time, rpi);
        title('Raw Pitot');                
    subplot(4,1,3)
        plot(time, rpo);
        title('Raw Power');                
    subplot(4,1,4)
        plot(time, rth);
        title('Raw Thermistor');                
        xlabel('Time (s)');
        
    eval(['print -depsc  '  num2str(figct)]);
    figct = figct + 1;
        
    if onlyRaw == 0 
         %Plot the Velocities
        figure(figct)
        subplot(3,1,1)
            plot(time, vx);
            title('Velocity X');        
        subplot(3,1,2)
            plot(time, vy);
            title('Velocity Y');                
        subplot(3,1,3)
            plot(time, vz);
            title('Velocity z');                
            xlabel('Time (s)');

        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

        figure(figct)
        subplot(3,1,1)
            plot(time, x);
            title('Position X');        
        subplot(3,1,2)
            plot(time, y);
            title('Position Y');                
        subplot(3,1,3)
            plot(time, z);
            title('Position z');                
            xlabel('Time (s)');

        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

        figure(figct)
            plot(y,x);
            title('XY Position plot');        
            xlabel('X (m)');
            ylabel('Y (m)');


        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

%         figure(figct)
%             plot3(y,x,z);
%             title('XYZ Position plot');        
%             xlabel('X (m)');
%             ylabel('Y (m)');
%             zlabel('Z (m)');
% 
%         eval(['print -depsc  '  num2str(figct)]);
%         figct = figct + 1;

        %plot the Pressures
        figure(figct)
        subplot(2,1,1)
            plot(time, dyn);
            title('Dynamic Pressure');        
        subplot(2,1,2)
            plot(time, sta);
            title('Static Pressure');                
            xlabel('Time (s)');
        
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;


        figure(figct)
            plot(lon, lat);
            title('Lat Lon Position plot');        
            xlabel ('Longitude (deg)');
            ylabel ('Latitude (deg)');
            
            hold on
            plot([-122.0534434, -122.053768, -122.0491093, -122.0494338],[36.9900606, 36.9886727, 36.9887338, 36.9900911], 'r+')
            plot([-122.0534434, -122.053768, -122.0491093, -122.0494338, -122.0534434],[36.9900606, 36.9886727, 36.9887338, 36.9900911, 36.9900606], 'r', 'LineWidth', 2)
            hold off
            
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

%         figure(figct)
%             plot3(lon,lat, hei);
%             title('Lat Lon Height Position plot'); 
%             xlabel ('Longitude (deg)');
%             ylabel ('Latitude (deg)');
%             zlabel ('Height (m)');
%         eval(['print -depsc  '  num2str(figct)]);
%         figct = figct + 1;

        
        figure(figct)
        subplot(3,1,1)
            plot(time, cog);
            title('Course Over Ground from GPS');        
        subplot(3,1,2)
            plot(time, sog);
            title('Speed Over Ground from GPS');                
        subplot(3,1,3)
            plot(time, sat);
            title('Satellites in Use');                
            xlabel('Time (ms)');
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

        figure(figct)
        subplot(2,3,1)
            plot(time, bgx);
            title('Bias Gyro X');
            ylabel('Radians/s');
        subplot(2,3,2)
            plot(time, bgy);
            title('Bias Gyro Y');        
        subplot(2,3,3)
            plot(time, bgz);
            title('Bias Gyro Z');        
        subplot(2,3,4)
            plot(time, bax);
            title('Bias Accel X');        
            xlabel('Time (ms)');
            ylabel ('m/s');
        subplot(2,3,5)
            plot(time, bay);
            title('Bias Accel Y');        
            xlabel('Time (ms)');
        subplot(2,3,6)
            plot(time, baz);
            title('Bias Accel Z');        
            xlabel('Time (ms)');
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

     figure(figct)
        subplot(3,1,1)
            plot(time, fl1);
            title('Diagnostics Float 1');        
        subplot(3,1,2)
            plot(time, fl2);
            title('Diagnostics Float 2');                
        subplot(3,1,3)
            plot(time, fl3);
            title('Diagnostics Float 3');                
            xlabel('Time (ms)');
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

     figure(figct)
        subplot(3,1,1)
            plot(time, sh1);
            title('Diagnostics Short 1');        
        subplot(3,1,2)
            plot(time, sh2);
            title('Diagnostics Short 2');                
        subplot(3,1,3)
            plot(time, sh3);
            title('Diagnostics Short 3');                
            xlabel('Time (ms)');
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

        
%      figure(figct)
%         subplot(2,1,1)
%             plot(time, sec);
%             title('GPS Seconds');        
%         subplot(2,1,2)
%             plot(diff(sec));
%             title('Update Rate');                
%         eval(['print -depsc  '  num2str(figct)]);
%         figct = figct + 1;
% 
%     end
        
        % Commanded vs Measured plots
        % ===========================
        figure(figct)
            plot(time(autoIdx), z(autoIdx));
            hold on
            plot(time(autoIdx), hc(autoIdx), 'r');
            hold off
            title('Height measured vs commanded');        
            xlabel ('Time (s)');
            ylabel ('Height (m)');
            grid on
            
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;


        figure(figct)
            plot(time(autoIdx), the(autoIdx)*180/pi);
            hold on
            plot(time(autoIdx), the_c(autoIdx)*180/pi, 'r');
            hold off
            title('Pitch measured vs commanded');        
            xlabel ('Time (s)');
            ylabel ('Pitch (deg)');
            grid on
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

        figure(figct)
            plot(time(autoIdx), um(autoIdx));
            hold on
            plot(time(autoIdx), uc(autoIdx), 'r');
            hold off
            title('Airspeed measured vs commanded');        
            xlabel ('Time (s)');
            ylabel ('Airspeed (m/s)');
            grid on
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;
        
        figure(figct)
            plot(time(autoIdx), phi(autoIdx)*180/pi);
            hold on 
            plot(time(autoIdx), phi_c(autoIdx)*180/pi, 'r');
            hold off
            title('Roll measured vs commanded');        
            xlabel ('Time (s)');
            ylabel ('Roll (deg)');
            grid on
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;
        

        figure(figct)
            plot(time(autoIdx), zeros(size(time(autoIdx))));
            hold
            plot(time(autoIdx), rhp(autoIdx)*180/pi, 'r');
            title('R high passed measured vs commanded');        
            xlabel ('Time (s)');
            ylabel ('Roll (deg)');
            
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

        figure(figct)
        subplot(3,1,1)
            plot(time(autoIdx), cog(autoIdx));
            title('Course Over Ground');
            grid on
        subplot(3,1,2)
            plot(time(autoIdx), sqrt(vx(autoIdx).^2+ vy(autoIdx).^2));
            title('Groundspeed');
            grid on
        subplot(3,1,3)
            plot(time(autoIdx), phi(autoIdx)*180/pi);
            title('Roll');                
            xlabel('Time (ms)');
            grid on
        eval(['print -depsc  '  num2str(figct)]);
        figct = figct + 1;

        
    end
end % if plots are required

%% Return Values
PosAtt = [phi the psi p q r x y z vx vy vz];
Raw = [rgx rgy rgz rax ray raz rmx rmy rmz rba rpi rpo rth];
if onlyRaw  == 0
    GPS = [lat lon hei cog sog sec];
    Bias = [bgx bgy bgz bax bay baz];
    AirDiag = [sta dyn oat];
end

