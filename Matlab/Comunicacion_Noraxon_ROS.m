
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Control On/Off del exoesqueleto %%%
%%%      mediante sensores EMG      %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Establecer conexión con ROS
clc,clear,close
rosshutdown
rosinit('192.168.1.133')    % IP del ordenador con ROS


%% Establecer conexión con Noraxon
[stream_config, sensor_selection] = noraxon_stream_init('127.0.0.1', '9220');
tiempo=0;
command=0;
threshold=[10 10];
mvc=300;
umbral_1 = 60
umbral_2 = 35
f_amp = [0, 0]
tic 

%% Crear publicaciones y establecer posición inicial.
pub_dch = rospublisher('/my_pose_dch', 'std_msgs/Float64MultiArray');
pub_izq = rospublisher('/my_pose_izq', 'std_msgs/Float64MultiArray');
HOME = [0.0, 0.0, 0.0];

msg_dch = rosmessage(pub_dch);
msg_dch.Data = HOME
send(pub_dch, msg_dch)

msg_izq = rosmessage(pub_izq);
msg_izq.Data = HOME
send(pub_izq, msg_izq)

pub = rospublisher('/my_topic', 'std_msgs/Int16MultiArray');
msg = rosmessage(pub);
msg.Data = [1, 1];
send(pub, msg);
pause(4)
msg.Data = [0, 0];
send(pub, msg);
movimiento = 1;

%% Bucle de de lectura de sensores EMG y envio de posición al exoesqueleto

t = timer('TimerFcn', 'stat=false; disp(''Timer!'')','StartDelay',7);
start(t)
stat = true

while tiempo<=180  %Está en segundos
    
    % Recoger datos Noraxon
    data = noraxon_stream_collect(stream_config, 0.2)
    
    % Datos de cada sensor
    f_amp(1)=mean(abs(data(1).samples(:)));
    f_amp(2)=mean(abs(data(2).samples(:)));
    f_amp(3)=mean(abs(data(3).samples(:)));
    f_amp(4)=mean(abs(data(4).samples(:)));
    
    % Control On/Off mediante el umbral
        % Control pierna derecha
    if f_amp(1) >= umbral_1 || f_amp(2) >= umbral_2
        msg.Data(1) = 1;
    else
        msg.Data(1) = 0;
    end

        % Control pierna izquierda
    if f_amp(3) >= umbral_1 || f_amp(4) >= umbral_2
        msg.Data(2) = 1;
    else
        msg.Data(2) = 0;
    end
    
    send(pub, msg); %Envio del mensaje de control a ROS

     % cambio de posicion
    if stat == 0       
        start(t)
        stat = true;
        if movimiento >= 7
            movimiento = 0;
        else
            movimiento = movimiento+1;
        end

    end
    
    % Posiciones preestablecidas
    switch movimiento
        case 0  %levantarse
            msg_dch.Data = [0.0, 0.0, 0.0];
            send(pub_dch, msg_dch);
    
            msg_izq.Data = [0.0, 0.0, 0.0];
            send(pub_izq, msg_izq);
        case 1  % Sentarse
            msg_dch.Data = [-1.7, -1.7, 0.0];
            send(pub_dch, msg_dch);

            msg_izq.Data = [-1.7, -1.7, 0.0];
            send(pub_izq, msg_izq);
        case 2  %levantarse
            msg_dch.Data = [0.0, 0.0, 0.0];
            send(pub_dch, msg_dch);
    
            msg_izq.Data = [0.0, 0.0, 0.0];
            send(pub_izq, msg_izq);
        case 3  %sentarse
            msg_dch.Data = [-1.7, -1.7, 0.0];
            send(pub_dch, msg_dch);

            msg_izq.Data = [-1.7, -1.7, 0.0];
            send(pub_izq, msg_izq);

        case 4  % extender rodilla dch
            msg_dch.Data = [-1.7, 0.0, 1.2];
            send(pub_dch, msg_dch);
        case 5  % flexionar rodilla dch
            msg_dch.Data = [-1.7, -1.7, 0.0];
            send(pub_dch, msg_dch);
    
        case 6  % extender rodilla izq
            msg_izq.Data = [-1.7, 0.0, -1.2];
            send(pub_izq, msg_izq);
        case 7  % flexionar rodilla izq
            msg_izq.Data = [-1.7, -1.7, 0.0];
            send(pub_izq, msg_izq);
    end

    command=round(f_amp*10/mvc);

 tiempo = toc;
        
end
