SUBDIRS = apt before_install  install before_script  script  after_success  after_failures  before_deploy  deploy  after_deploy  after_script

-include Makefile.env

.PHONY: subdirs $(SUBDIRS)

all: $(SUBDIRS)
	@echo "# $@ $^"

$(SUBDIRS):
	@echo "# task: $@"
	@if [ -f Makefile.$@ ] ;then \
	  $(MAKE) -f Makefile.$@ $@ ; \
	fi
