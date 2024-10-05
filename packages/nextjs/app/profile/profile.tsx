
"use client";
import { useAccount } from "@starknet-react/core";
import { useEffect, useState } from "react";

export function Profile() {
    const { address, status, chainId } = useAccount();

    const [nfts, setNfts] = useState([]);
 
    useEffect(() => {
      async function fetchNFTs() {
        if (!address) return
        console.log(address)
        let res = await fetch(`http://127.0.0.1:3000/nfts?address=${address}`)
        let data = await res.json()
        console.log(data)
        setNfts(data)
      }
      fetchNFTs()
    }, [address])

  return (
    <div className="flex flex-row gap-y-6 lg:gap-y-8 py-8 lg:py-12 justify-around items-center">
      {nfts && nfts.map((nft) => (
          <div className="card bg-base-100 w-96 shadow-xl">
          <figure>
            <img
              src={`https://dweb.link/ipfs/QmZS7maV678eJW7wJaVXJc28aKXzdZrwS1hmBmSy6bUVJh/${nft}.jpg`}
              alt="Shoes" />
          </figure>
          <div className="card-body">
            <h2 className="card-title">Stark Hero #{nft}</h2>
            <div className="card-actions justify-end">
              <button className="btn btn-primary">Buy Now</button>
            </div>
          </div>
        </div>
      ))}
    </div>
  );
}
