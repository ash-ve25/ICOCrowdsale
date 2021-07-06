const CrowdSale = artifacts.require("CrowdSale");

module.exports = function (deployer) {
  deployer.deploy(CrowdSale);
};
