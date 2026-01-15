#!/usr/bin/bash

#### get tunneling info
XDG_RUNTIME_DIR=""
ipnport=your_port_number_here
ipnip=$(hostname -i)

#### print tunneling instructions
echo -e "\n\n   Copy/Paste this in your local terminal to ssh tunnel with remote "
echo        "   ------------------------------------------------------------------"
echo        "   ssh -N -L $ipnport:$ipnip:$ipnport $USER@taco.grid.bcm.edu    "
echo        "   ------------------------------------------------------------------"
echo -e "\n\n   Then open a browser on your local machine to the following address"
echo        "   ------------------------------------------------------------------"
echo        "   localhost:$ipnport                                                "
echo -e     "   ------------------------------------------------------------------\n\n"
sleep 1

#### start code-server from Docker image using Singularity
singularity run --bind $HOME \
		--bind /your/path/here \
                --env PASSWORD=your_password_here \
                docker://codercom/code-server \
                --bind-addr $ipnip:$ipnport
