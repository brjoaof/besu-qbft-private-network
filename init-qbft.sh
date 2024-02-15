#!/bin/bash
# Script to create a private network using QBFT

if [ "$1" == "" ]; then
    echo ""
    echo "Usage: $0 besu-image-name"
    echo "Example: $0 hyperledger/besu"
    echo ""
else
    #Genesis Generation
    cd genesis-generator
    rm -rf networkFiles #Delete previous directory

    sed -i "s#image:.*#image: $1#" docker-compose.yaml #Set image name

    docker rm -f node-1 node-2 node-3 node-4 genesis-generator > /dev/null 2>&1 #Delete previous containers with the same name
    docker compose up

    #Nodes Creation
    count=1
    rpc_http_port=8545
    p2p_port=30303
    for dir in networkFiles/keys/*; do
        rm -rf ../node-$count #Delete previous directories with the same name
        mkdir -p ../node-$count/data/ #Create the node directory
        cp -f networkFiles/genesis.json ../node-$count/ #Copy the generated genesis to the node directory
        cp -rf $dir/* ../node-$count/data/ #Copy all files to /data 
        #Set http and p2p port in node config.toml
        sed -e "s#rpc-http-port.*#rpc-http-port=$rpc_http_port#" -e "s#p2p-port=.*#p2p-port=$p2p_port#" config.toml > ../node-$count/config.toml 
        #Set the image name in the node docker-compose.yaml
        sed -e "s#image:.*#image: $1#" -e "s#container_name:.*#container_name: node-$count#" node-docker-compose.yaml > ../node-$count/docker-compose.yaml
        ((count++))
        ((rpc_http_port++))
        ((p2p_port++))
    done

    #Get enode
    cd ../node-1/data
    enode=$(cut -c3- < key.pub)

    #Set bootnodes in nodes 2, 3 and 4. (localhost:127.0.0.1 - P2P Port node-1:30303)
    cd ../../
    for node in {2..4}; do
        echo -e "\n\nbootnodes=[\"enode://$enode@127.0.0.1:30303\"]" >> node-$node/config.toml
    done

    docker rm node-1 node-2 node-3 node-4 genesis-generator > /dev/null 2>&1 #To avoid errors, delete previous containers with the same name

    #Start QBFT Network
    docker compose up
fi





