# Lighthouse Yocto meta layer

Meta-Rpi commit: b10b0f1bf64ad7e8b1ab00e0a67f0c6e77ef0a97
Cirrus Audio Card driver: http://www.horus.com/~hias/cirrus-driver.html

Usage:

1. Setup your build host - the machine where you're going to build Yocto image. To do this follow [this guide](http://www.yoctoproject.org/docs/2.2/mega-manual/mega-manual.html) or use ready-to-go Ubuntu [Docker image](https://hub.docker.com/r/azasypkin/lighthouse/);
2. Create a separate directory where you'll store all required meta layers and checkout all of them:
  1. `$ git clone -b krogoth git://git.yoctoproject.org/poky.git`
  2. `$ git clone -b krogoth git://git.openembedded.org/meta-openembedded`
  3. `$ git clone -b krogoth git://git.yoctoproject.org/meta-raspberrypi`
  4. `$ git clone -b master git://github.com/project-lighthouse/yocto-meta-layer`
3. If you use Docker image then the folder with all repositories above should be volume mounted. Then run environment initialization script from `poky` repository.
4. `$ source poky/oe-init-build-env rpi-build/`
5. After the previous command you'll end up inside of `rpi-build` folder, so inside this folder do the following steps:
    1. `$ mkdir -p ./conf`
    2. `$ cp yocto-meta-layer/conf/local.conf.sample rpi-build/conf/local.conf`
    3. `$ cp yocto-meta-layer/conf/bblayers.conf.sample rpi-build/conf/bblayers.conf`
    4. Open `rpi-build/conf/bblayers.conf` and make sure paths to the repositories are correct. Adjust if needed.
6. Once everything is ready, run `$ bitbake console-image`. It can take few hours for the first time, will be much faster after that.
7. Once you're done, go to the `yocto-meta-layer/scripts` folder;
8. `$ ./prepare-image.sh image-v0.0.7.img`.