import React, {useState, useEffect, useContext}from 'react'
import web3Modal from "web3modal";
import {ethers} from "ethers";
import Router from "next/router";
import axios from 'axios';
import {create as ipfsHttpClient} from "ipfs-Http-Client";
// internal imports

import { NFTMarketplaceAddress, NFTMarketplaceABI } from './constants';
 

// fetch smart contract
const fetchContract = (singerOrProvider)=> new ethers.Contract(
  NFTMarketplaceAddress,
  NFTMarketplaceABI,
  singerOrProvider,
)

/// conecting with smart contract
const connectingWithSmartContract = async()=>
{
  try {
    const web3Modal = new web3Modal();
    const connection = await web3Modal.connect();
    const provider = new ethers.providers.Web3Provider(connection);
    const signer = provider.getSigner();
    const contract = fetchContract(signer);
    return contract;
  } catch (error) {
    console.log("Something went wrong with contract");
    
  }
};

export const NFTMarketPlaceContext =  React.createContext();


export const NFTMarketPlaceProvider = (({children})=> {
   const titleData = "Discover, collect and sell nfts";
   
   const checkContract = async()=>{
      const contract = await connectingWithSmartContract();
      console.log();

   };
   
   return (
        <NFTMarketPlaceContext.Provider 
        value={{
          checkContract,
          titleData,
          }}>
          {children}
        </NFTMarketPlaceContext.Provider>
    )
}) 