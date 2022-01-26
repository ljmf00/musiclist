#!/usr/bin/env rdmd
module refres_gateways;

import std.file;
import std.array;
import std.range;
import std.string;
import std.format;
import std.parallelism;
import std.stdio;
import std.path;
import std.algorithm;
import std.random;
import std.experimental.logger;

import std.net.curl;
import etc.c.curl;

import core.time;
import core.sync.mutex;
import core.thread;

static immutable GATEWAYS = [
    "https://ipfs.io/ipfs/%s",
    "https://dweb.link/ipfs/%s",
    "https://gateway.ipfs.io/ipfs/%s",
    "https://ipfs.infura.io/ipfs/%s",
    "https://infura-ipfs.io/ipfs/%s",
    "https://ninetailed.ninja/ipfs/%s",
    "https://ipfs.globalupload.io/%s",
    "https://10.via0.com/ipfs/%s",
    "https://ipfs.eternum.io/ipfs/%s",
    "https://hardbin.com/ipfs/%s",
    "https://gateway.blocksec.com/ipfs/%s",
    "https://cloudflare-ipfs.com/ipfs/%s",
    "https://astyanax.io/ipfs/%s",
    "https://cf-ipfs.com/ipfs/%s",
    "https://ipfs.cf-ipfs.com/%s",
    "https://ipns.co/ipfs/%s",
    "https://ipfs.mrh.io/ipfs/%s",
    "https://gateway.originprotocol.com/ipfs/%s",
    "https://gateway.pinata.cloud/ipfs/%s",
    "https://ipfs.doolta.com/ipfs/%s",
    "https://ipfs.sloppyta.co/ipfs/%s",
    "https://ipfs.busy.org/ipfs/%s",
    "https://ipfs.greyh.at/ipfs/%s",
    "https://gateway.serph.network/ipfs/%s",
    "https://jorropo.ovh/ipfs/%s",
    "https://jorropo.net/ipfs/%s",
    "https://gateway.temporal.cloud/ipfs/%s",
    "https://ipfs.fooock.com/ipfs/%s",
    "https://cdn.cwinfo.net/ipfs/%s",
    "https://aragon.ventures/ipfs/%s",
    "https://ipfs-cdn.aragon.ventures/ipfs/%s",
    "https://permaweb.io/ipfs/%s",
    "https://ipfs.stibarc.com/ipfs/%s",
    "https://ipfs.best-practice.se/ipfs/%s",
    "https://2read.net/ipfs/%s",
    "https://ipfs.2read.net/ipfs/%s",
    "https://storjipfs-gateway.com/ipfs/%s",
    "https://ipfs.runfission.com/ipfs/%s",
    "https://ipfs.trusti.id/ipfs/%s",
    "https://ipfs.overpi.com/ipfs/%s",
    "https://gateway.ipfs.lc/ipfs/%s",
    "https://ipfs.leiyun.org/ipfs/%s",
    "https://ipfs.ink/ipfs/%s",
    "https://ipfs.oceanprotocol.com/ipfs/%s",
    "https://d26g9c7mfuzstv.cloudfront.net/ipfs/%s",
    "https://ipfsgateway.makersplace.com/ipfs/%s",
    "https://gateway.ravenland.org/ipfs/%s",
    "https://ipfs.funnychain.co/ipfs/%s",
    "https://ipfs.telos.miami/ipfs/%s",
    "https://robotizing.net/ipfs/%s",
    "https://ipfs.mttk.net/ipfs/%s",
    "https://ipfs.fleek.co/ipfs/%s",
    "https://ipfs.jbb.one/ipfs/%s",
    "https://ipfs.yt/ipfs/%s",
    "https://jacl.tech/ipfs/%s",
    "https://hashnews.k1ic.com/ipfs/%s",
    "https://ipfs.vip/ipfs/%s",
    "https://ipfs.k1ic.com/ipfs/%s",
    "https://ipfs.drink.cafe/ipfs/%s",
    "https://ipfs.azurewebsites.net/ipfs/%s",
    "https://gw.ipfspin.com/ipfs/%s",
    "https://ipfs.kavin.rocks/ipfs/%s",
    "https://ipfs.denarius.io/ipfs/%s",
    "https://ipfs.mihir.ch/ipfs/%s",
    "https://bluelight.link/ipfs/%s",
    "https://crustwebsites.net/ipfs/%s",
    "http://3.211.196.68:8080/ipfs/%s",
    "https://ipfs0.sjc.cloudsigma.com/ipfs/%s",
    "https://ipfs-tezos.giganode.io/ipfs/%s",
    "http://183.252.17.149:82/ipfs/%s",
    "http://ipfs.genenetwork.org/ipfs/%s",
    "https://ipfs.eth.aragon.network/ipfs/%s",
    "https://ipfs.smartholdem.io/ipfs/%s",
    "https://bin.d0x.to/ipfs/%s",
    "https://ipfs.xoqq.ch/ipfs/%s",
    "http://natoboram.mynetgear.com:8080/ipfs/%s",
    "https://video.oneloveipfs.com/ipfs/%s",
    "http://ipfs.anonymize.com/ipfs/%s",
    "https://ipfs.noormohammed.tech/ipfs/%s",
    "https://ipfs.taxi/ipfs/%s",
    "https://ipfs.scalaproject.io/ipfs/%s",
    "https://search.ipfsgate.com/ipfs/%s",
    "https://ipfs.itargo.io/ipfs/%s",
    "https://ipfs.decoo.io/ipfs/%s",
    "https://ivoputzer.xyz/ipfs/%s",
    "https://alexdav.id/ipfs/%s",
    "https://ipfs.uploads.nu/ipfs/%s",
    "https://hub.textile.io/ipfs/%s",
    "https://ipfs1.pixura.io/ipfs/%s",
    "https://ravencoinipfs-gateway.com/ipfs/%s",
    "https://konubinix.eu/ipfs/%s",
    "https://ipfs.clansty.com/ipfs/%s",
    "https://3cloud.ee/ipfs/%s",
    "https://ipfs.tubby.cloud/ipfs/%s",
    "https://ipfs.lain.la/ipfs/%s",
    "https://ipfs.adatools.io/ipfs/%s",
    "https://ipfs.kaleido.art/ipfs/%s",
    "https://ipfs.slang.cx/ipfs/%s",
    "https://ipfs.arching-kaos.com/ipfs/%s",
    "https://storry.tv/ipfs/%s",
    "https://ipfs.kxv.io/ipfs/%s",
    "https://ipfs-nosub.stibarc.com/ipfs/%s",
    "https://ipfs.1-2.dev/ipfs/%s",
    "https://dweb.eu.org/ipfs/%s",
    "https://permaweb.eu.org/ipfs/%s",
    "https://ipfs.namebase.io/ipfs/%s",
    "https://ipfs.tribecap.co/ipfs/%s",
    "https://ipfs.kinematiks.com/ipfs/%s",
    "https://ipfs.campus-site.net:8081/ipfs/%s",
    "https://c4rex.co/ipfs/%s",
    "https://ipfs.webit.re/ipfs/%s",
    "https://ipfs.voxhost.fr/ipfs/%s",
    "http://rx14.co.uk/ipfs/%s",
    "https://xmine128.tk/ipfs/%s",
    "https://upload.global/ipfs/%s",
    "https://ipfs.jes.xxx/ipfs/%s",
    "https://siderus.io/ipfs/%s",
];

static immutable TOR_GATEWAYS = [
    "http://fzdqwfb5ml56oadins5jpuhe6ki6bk33umri35p5kt2tue4fpws5efid.onion/ipfs/%s",
];


bool checkGateway(string gateway)
{
    static immutable HELLO_STRING = "Hello from IPFS Gateway Checker";
    static immutable HELLO_HASH = "bafybeifx7yeb55armcsxwwitkymga5xf53dxiarykms3ygqic223w5sk3m";

    immutable gatewayURL = gateway.stripRight("%s");

    log(LogLevel.trace, format!"Requesting %s"(gatewayURL));
    try {
        if (byLine(format(gateway, HELLO_HASH)).front == HELLO_STRING)
        {
            info(format!"Success: %s"(gatewayURL));
            return true;
        }
    } catch (CurlTimeoutException e) {
        error(format!"Timeout %s"(gatewayURL));
        return false;
    } catch (HTTPStatusException e) {
        error(format!"Fail %s"(gatewayURL));
        return false;
    } catch (CurlException e) {
        error(format!"Fail %s"(gatewayURL));
        return false;
    }

    error(format!"Fail: %s"(gatewayURL));
    return false;
}

void requestGateway(string gw, string hash, bool tor)
{
    immutable gwURL = gw.stripRight("%s");
    auto client = HTTP();
    if (tor)
    {
        client.proxy = "127.0.0.1";
        client.proxyPort = 9050;
        client.proxyType = CurlProxy.socks5;
    }
    log(LogLevel.trace, format!"Requesting %s on %s"(hash, gwURL));
    try {
        if (byChunk(format(gw, hash), 10, client).front)
        {
            info(format!"Success: %s on %s"(hash, gwURL));
            return;
        }
    } catch (CurlTimeoutException e) {
        error(format!"Timeout %s on %s"(hash, gwURL));
        return;
    } catch (HTTPStatusException e) {
        error(format!"Fail %s on %s"(hash, gwURL));
        return;
    } catch (CurlException e) {
        error(format!"Fail %s on %s"(hash, gwURL));
        return;
    }

    error(format!"Fail: %s on %s"(hash, gwURL));
}

void main()
{
    shared string[] availableGW;

    new Thread({
        foreach(gw; new TaskPool(25).parallel(GATEWAYS))
            if (checkGateway(gw))
                availableGW ~= gw;
    }).start();

    auto hashes = dirEntries("store/metadata/", SpanMode.breadth)
        .filter!(f => f.isFile && !f.isSymlink)
        .map!(baseName)
        .array;

    while(true) {
        foreach(hash; randomShuffle(hashes))
        {
            if (availableGW.empty) {
                Thread.sleep(dur!"seconds"(2));
                continue;
            }
            log(LogLevel.trace, format!"Process %s"(hash));
            foreach(gw; taskPool.parallel(availableGW))
                requestGateway(gw, hash, false);

            /* foreach(gw; taskPool.parallel(TOR_GATEWAYS)) */
            /*     requestGateway(gw, hash, true); */
        }
    }

}
