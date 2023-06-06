const Moralis = require("moralis").default;
const fs = require("fs"); 
const { env } = require("process");

async function uploadToIpfs() {

    await Moralis.start({
        apiKey: "",
    });
    //const ipfsHash = file.cid.toString();

    const uploadArray = [
        {
            path: "IPFS_test.docx",
        },
    ];

    const response = await Moralis.EvmApi.ipfs.uploadFolder({
        abi: uploadArray,
    });

    console.log(response.result)
}

uploadToIpfs();