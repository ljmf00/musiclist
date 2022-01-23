import { NFTStorage, File } from 'nft.storage'
import { pack } from 'ipfs-car/pack'
import process from 'process'
import minimist from 'minimist'
import { Web3Storage, getFilesFromPath } from 'web3.storage'
import fs from 'fs'

const NS_API_KEY = fs.readFileSync('ns-api-key.txt','utf8').trim();
const WEB3_API_KEY = fs.readFileSync('web3-api-key.txt','utf8').trim();

const args = minimist(process.argv.slice(2))

const nsclient = new NFTStorage({ token: NS_API_KEY })
const web3client = new Web3Storage({ token: WEB3_API_KEY })

const web3files = []
const nsfiles = []

function getFiles (dir, files_){
    files_ = files_ || [];
    var files = fs.readdirSync(dir);
    for (var i in files){
        var name = dir + '/' + files[i];
        if (fs.statSync(name).isDirectory()){
            getFiles(name, files_);
        } else {
            files_.push(name);
        }
    }
    return files_;
}

for (const path of args._) {
  const pathFiles = await getFilesFromPath(path)
  web3files.push(...pathFiles)

  nsfiles.push(...getFiles(path).map(f => new File([fs.readFileSync(f)], f)))
}


const web3cid = await web3client.put(web3files)
console.log(web3cid)
const nscid = await nsclient.storeDirectory(nsfiles)
console.log(nscid)
