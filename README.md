# Spreadsheet Fuel

[![Gem Version](https://badge.fury.io/rb/spreadsheet_fuel.svg)](https://badge.fury.io/rb/spreadsheet_fuel) [![Build Status](https://travis-ci.com/bluemarblepayroll/spreadsheet_fuel.svg?branch=master)](https://travis-ci.com/bluemarblepayroll/spreadsheet_fuel) [![Maintainability](https://api.codeclimate.com/v1/badges/b03892fff9af19eaa7ee/maintainability)](https://codeclimate.com/github/bluemarblepayroll/spreadsheet_fuel/maintainability) [![Test Coverage](https://api.codeclimate.com/v1/badges/b03892fff9af19eaa7ee/test_coverage)](https://codeclimate.com/github/bluemarblepayroll/spreadsheet_fuel/test_coverage) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This library is a plugin for [Burner](https://github.com/bluemarblepayroll/burner).  It adds jobs focused around spreadsheet processing such as reading and writing Microsoft Excel Open XML spreadsheets (.xlsx files).

## Installation

To install through Rubygems:

````bash
gem install spreadsheet_fuel
````

You can also add this to your Gemfile:

````bash
bundle add spreadsheet_fuel
````
## Jobs

Refer to the [Burner](https://github.com/bluemarblepayroll/burner) library for more specific information on how Burner works.  This section will just focus on what this library directly adds.

* **spreadsheet_fuel/deserialize/xlsx** [register, sheet_mappings]: Take the register, parse it as a Microsoft Excel Open XML spreadsheet and store the sheet data in the specified sheet_mappings' registers.  Each sheet mapping specifies which sheet to read and where to place the parsed data.  If no sheet mappings are specified then the default sheet will be parsed and placed in the register.
* **spreadsheet_fuel/serialize/xlsx** [register, sheet_mappings]: Create a Microsoft Excel Open XML workbook and write all specified register data into their respective sheets.  The sheet_mappings will specify which sheets get data and from which register.

## Examples

### Reading an Excel Spreadsheet

Let's use the example fixture file as an example XLSX file to read and parse (located at `spec/fixtures/patients_and_notes.xlsx`).  We could execute the following Burner pipeline:

````ruby
pipeline = {
  jobs: [
    {
      name: 'read',
      type: 'b/io/read',
      path: File.join('spec', 'fixtures', 'patients_and_notes.xlsx') # change as necessary
    },
    {
      name: 'parse',
      type: 'spreadsheet_fuel/deserialize/xlsx',
      sheet_mappings: [
        { sheet: 'Patients', register: 'patients' },
        { sheet: 'Notes',    register: 'notes' }
      ]
    },
  ],
  steps: %w[read parse]
}

payload = Burner::Payload.new

Burner::Pipeline.make(pipeline).execute(payload: payload)
````

Inspecting the payload's registers would now look something like this:

````ruby
patients = payload[:patients] # [%w[chart_number first_name last_name], ...]
notes    = payload[:notes] # [%w[emp_number note_number contents],, ...]
````

### Writing an Excel Spreadsheet

Let's do an exact opposite of the above example.  Let's say we would like to write a spreadsheet given a few registers of data:

````ruby
pipeline = {
  jobs: [
    {
      name: 'load_patients',
      type: 'b/value/static',
      register: :patients,
      value: [
        %w[chart_number first_name last_name],
        [123, 'Bozo', 'Clown'],
        ['A456', nil, 'Rizzo'],
        %w[Z789 Hops Bunny]
      ]
    },
    {
      name: 'load_notes',
      type: 'b/value/static',
      register: :notes,
      value: [
        %w[emp_number note_number contents],
        ['A456', 1, 'Hello world!'],
        [nil, 2, 'Hello, again!'],
        ['Z789', 1, 'Something something…']
      ]
    },
    {
      name: 'write_workbook',
      type: 'spreadsheet_fuel/serialize/xlsx',
      register: :spreadsheet,
      sheet_mappings: [
        { sheet: 'Patients', register: :patients },
        { sheet: 'Notes',    register: :notes }
      ]
    },
  ],
  steps: %w[load_patients load_notes write_workbook]
}

payload = Burner::Payload.new

Burner::Pipeline.make(pipeline).execute(payload: payload)
````

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check spreadsheet_fuel.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/spreadsheet_fuel.git)
4. Navigate to the root folder (cd spreadsheet_fuel)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````bash
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````bash
bundle exec guard
````

Also, do not forget to run Rubocop:

````bash
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update `lib/spreadsheet_fuel/version.rb` using [semantic versioning](https://semver.org/)
3. Install dependencies: `bundle`
4. Update `CHANGELOG.md` with release notes
5. Commit & push master to remote and ensure CI builds master successfully
6. Run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Code of Conduct

Everyone interacting in this codebase, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bluemarblepayroll/spreadsheet_fuel/blob/master/CODE_OF_CONDUCT.md).

## License

This project is MIT Licensed.
