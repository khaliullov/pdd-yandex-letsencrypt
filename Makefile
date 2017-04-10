mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
mkfile_dir  := $(patsubst %/,%,$(dir $(mkfile_path)))
build_dir   := $(mkfile_dir)

DOMAIN      :=
TOKEN       :=

VIRTUALENV  := $(shell which virtualenv 2>/dev/null || echo virtualenv)

ifeq (,$(DOMAIN))
    $(error You must specify DOMAIN= to sign)
endif

ifeq (,$(TOKEN))
    $(error You must specify TOKEN= to access ppd.yandex.ru API)
endif

.PHONY: all clean
all: $(build_dir)/env accounts
	. $(build_dir)/env/bin/activate; \
	PROVIDER=yandex LEXICON_YANDEX_TOKEN=$(TOKEN) $(mkfile_dir)/dehydrated \
	    --cron --domain $(DOMAIN) \
	    --hook $(mkfile_dir)/dehydrated.default.sh --challenge dns-01

clean:
	rm -rf $(build_dir)/certs $(build_dir)/accounts $(build_dir)/lock
clean-all: clean
	rm -rf $(build_dir)/env

accounts:
	$(mkfile_dir)/dehydrated --register --accept-terms

$(build_dir)/env:
	$(VIRTUALENV) $(build_dir)/env
	$(build_dir)/env/bin/pip install -r $(mkfile_dir)/requirements.txt
