## Install OTBR environment to a new Raspberry Pi 5

1. Clone Scrpit code.

    ```bash
    git clone https://github.com/hmxf/sysMgmt
    ```
2. Configure base environment.

    ```bash
    cd sysMgmt/config_base && chmod +x *.sh
    ./base_config.sh
    sudo init 6
    ```
3. Configure system environment.

    ```bash
    cd sysMgmt/config_x729 && chmod +x *.sh
    ./sys_config.sh
    sudo init 6
    ```
4. Choose ONE of below to Install OTBR.

    1. Docker based.

        ```bash
        cd sysMgmt/config_otbr_docker && chmod +x *.sh
        ./install_otbr_docker.sh
        sudo init 6
        ```
    
        After system started, use below command to use OTBR.

        ```bash
        docker ps -a
        docker logs otbr
        docker exec -it otbr ot-ctl
        ```

    2. Self-built.

        ```bash
        cd sysMgmt/config_otbr_source && chmod +x *.sh
        ./install_otbr_source.sh
        sudo init 6
        ```

        After system started, use below commands to verify if OTBR was started.

        ```bash
        sudo service mdns status
        sudo service otbr-agent status
        sudo service otbr-web status
        ```

5. Configure the OTBR network settings

    1. Configure OpenThread Border Router's network parameters

    2. Assign host ipv6 address

6. Install OTBR Monitor

    ```bash
    cd otbr_docker_daemon
    chmod +x *.sh
    ./install.sh
    ```
