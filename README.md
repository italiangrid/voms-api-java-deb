# voms-api-java-deb

The Deb packaging code for VOMS Java APIs version >= 3.0

In order to build deb packages for `voms-java-api` run the following command:
```bash
  make tag=3.x
```

The `tag` parameter specifies the tar or branch of the code that you're 
willing to build.

The script lets you specify a location for getting a maven settings file that 
will be included in the source tarball included in the source rpm. This is needed 
in order to be able to use snaspshot dependencies and succeed in an ETICS mock 
repackaging step. If no value is given, the default maven mirror @ CNAF is used. 
To use the CERN maven mirror you can use the following value:

```bash
  make tag=3.x mirror_conf_url=https://raw.github.com/italiangrid/build-settings/master/maven/cern-mirror-settings.xml
```
