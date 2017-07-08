# Log Parse

A simple log parsing program

## Installation

Clone the repository

```
git clone git@github.com:kornypoet/log_parse.git
```

Install gem dependencies

```
cd log_parse
bundle install
```

Run tests

```
bundle exec rake spec
```

Run syntax checker

```
bundle exec rake rubocop
```

Install log_parse locally

```
bundle exec rake install
```

## Usage

```
log_parse --help
Usage: log_parse [options] FILE
    -c, --count FIELD                Count occurrences of FIELD. Default source_address
    -f, --filter FIELD=VALUE         Filter by VALUE in FIELD. Default protocol=TLSv1
    -d, --debug                      Run in debug mode. Default false
```

Basic usage if installed locally from above. If running from the repository root, use `bundle exec exe/log_parse`

```
log_parse spec/fixtures/example.log
```

Specify a different field to bucket counts on

```
log_parse spec/fixtures/example.log --count dest_address
```

Specify a different field and value to filter by

```
log_parse spec/fixtures/example.log --filter response_status=302
```

Run in debug mode for additional output

```
log_parse spec/fixtures/example.log --debug
```
