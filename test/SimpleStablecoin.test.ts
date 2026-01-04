import { expect } from "chai";
import { network } from "hardhat";

const { ethers } = await network.connect();

describe("SimpleStablecoin (basic flows)", function () {
  let SimpleStablecoin: any;
  let stable: any;
  let owner: any;
  let issuer: any;
  let user: any;

  beforeEach(async function () {
    [owner, issuer, user] = await ethers.getSigners();
    SimpleStablecoin = await ethers.getContractFactory("SimpleStablecoin");
    stable = await SimpleStablecoin.deploy("EUR Stable POC", "EURp", issuer.address);
    await stable.waitForDeployment();
  });

  it("sets issuer correctly", async function () {
    expect(await stable.issuer()).to.equal(issuer.address);
  });

  it("allows issuer to request issuance and emits event", async function () {
    await expect(stable.connect(issuer).requestIssuance(user.address, ethers.parseEther("100"), "ref1"))
      .to.emit(stable, "IssuanceRequested")
      .withArgs(user.address, ethers.parseEther("100"), "ref1");
  });

  it("allows owner to mint after issuance (privileged)", async function () {
    await stable.connect(owner).mintFor(user.address, ethers.parseEther("100"));
    expect(await stable.balanceOf(user.address)).to.equal(ethers.parseEther("100"));
  });

  it("allows user to request redemption and emits event", async function () {
    await stable.connect(owner).mintFor(user.address, ethers.parseEther("50"));
    await expect(stable.connect(user).requestRedemption(ethers.parseEther("25"), "red1"))
      .to.emit(stable, "RedemptionRequested")
      .withArgs(user.address, ethers.parseEther("25"), "red1");
  });

  it("allows issuer to burn after redemption", async function () {
    await stable.connect(owner).mintFor(user.address, ethers.parseEther("60"));
    await stable.connect(user).requestRedemption(ethers.parseEther("60"), "red2");
    await stable.connect(issuer).burnFromIssuer(user.address, ethers.parseEther("60"));
    expect(await stable.balanceOf(user.address)).to.equal(0);
  });

  it("respects pause and unpause from owner", async function () {
    await stable.connect(owner).pause();
    await expect(stable.connect(issuer).requestIssuance(user.address, ethers.parseEther("1"), "refx")).to.be.revertedWithCustomError(stable, "EnforcedPause");
    await stable.connect(owner).unpause();
    await expect(stable.connect(issuer).requestIssuance(user.address, ethers.parseEther("1"), "refx")).to.emit(stable, "IssuanceRequested");
  });
});
