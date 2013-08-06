name=libvoms3-java
tag=3.x

# the GitHub repo where source tarball will be fetched from
git=https://github.com/italiangrid/voms-api-java.git

# needed dirs
debbuild_dir=$(shell pwd)/debbuild

# determine the pom version and set the deb version
pom_version=$(shell grep "<version>" $(name)-$(deb_version)/pom.xml | head -1 | sed -e 's/<version>//g' -e 's/<\/version>//g' -e "s/[ \t]*//g")
deb_version=3.0.1
deb_age=1

# mvn settings mirror conf url
mirror_conf_url=https://raw.github.com/italiangrid/build-settings/master/maven/cnaf-mirror-settings.xml

# name of the mirror settings file 
mirror_conf_name=mirror-settings.xml

mvn_settings=-s $(mirror_conf_name)

.PHONY: clean deb

all: deb

print-info:
	@echo
	@echo
	@echo "Packaging $(name) fetched from $(git) for tag $(tag)."
	@echo "Maven settings: $(mirror_conf_url)"
	@echo
	@echo

prepare-sources: sanity-checks clean
	# get the source, without git files
	git clone $(git) $(name)-$(deb_version)
	cd $(name)-$(deb_version) && git archive --format=tar --prefix=$(name)-$(deb_version)/ $(tag) > $(name)_$(deb_version).tar
	# add maven mirror settings
	wget --no-check-certificate $(mirror_conf_url) -O $(name)-$(deb_version)/$(mirror_conf_name)
	tar -r -f $(name)-$(deb_version)/$(name)_$(deb_version).tar $(name)-$(deb_version)/$(mirror_conf_name)

prepare-deb-files: prepare-sources
	sed -e 's#@@DEB_VERSION@@#$(deb_version)-$(deb_age)#g' debian/changelog.in > debian/changelog
	sed -e 's#@@POM_VERSION@@#$(pom_version)#g' debian/$(name).install.in > debian/$(name).install
	sed -e 's#@@POM_VERSION@@#$(pom_version)#g' debian/$(name).links.in > debian/$(name).links
	sed -e 's#@@MVN_SETTINGS@@#$(mvn_settings)#g' debian/rules.in > debian/rules && chmod 755 debian/rules
	cp -r debian $(name)-$(deb_version)
	tar -r -f $(name)-$(deb_version)/$(name)_$(deb_version).tar $(name)-$(deb_version)/debian && gzip $(name)-$(deb_version)/$(name)_$(deb_version).tar
	cp $(name)-$(deb_version)/$(name)_$(deb_version).tar.gz $(name)_$(deb_version).tar.gz
	rm -rf $(name)-$(deb_version)

prepare-debbuilddir: prepare-deb-files
	mkdir -p $(debbuild_dir)
	mv $(name)_$(deb_version).tar.gz $(name)_$(deb_version).src.tar.gz
	cp $(name)_$(deb_version).src.tar.gz $(debbuild_dir)/$(name)_$(deb_version).orig.tar.gz
	cd $(debbuild_dir) && tar xzvf $(name)_$(deb_version).orig.tar.gz

deb-src: prepare-debbuilddir
	cd $(debbuild_dir) && dpkg-source -b $(name)-$(deb_version)

deb: print-info deb-src
	cd $(debbuild_dir)/$(name)-$(deb_version) && debuild -us -uc

clean:
	@rm -rf $(name)-$(deb_version) $(name)_$(deb_version).src.tar.gz $(debbuild_dir) debian/$(name).install debian/$(name).links debian/rules debian/changelog

sanity-checks:
ifndef tag
	$(error tag is undefined)
endif
