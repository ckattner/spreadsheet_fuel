# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module SpreadsheetFuel
  module Library
    module Serialize
      # This job can take in one or many registers and create a Microsoft Excel Open XML Spreadsheet
      # file out of them.  Each register will be written to the specified sheets within
      # the workbook.  If no sheet_mappings are entered, then the input register will be used
      # for input and output and only one sheet will be created with the name 'Sheet1'.
      #
      # Expected Payload[register|sheet_mappings.register] input: array of arrays.
      # Payload[register|sheet_mappings.register] output: XLSX data string blob.
      class Xlsx < Burner::JobWithRegister
        DEFAULT_SHEET = 'Sheet1'

        attr_reader :sheet_mappings

        def initialize(name: '', register: Burner::DEFAULT_REGISTER, sheet_mappings: nil)
          super(name: name, register: register)

          @sheet_mappings = Modeling::SheetMapping.array(sheet_mappings)

          # If no sheets/register mappings are specified then lets just use the default
          # sheet and the current register.
          if @sheet_mappings.empty?
            @sheet_mappings << Modeling::SheetMapping.new(register: register, sheet: DEFAULT_SHEET)
          end

          freeze
        end

        def perform(output, payload)
          output.detail("Writing spreadsheet to register: #{register}")

          # This will implicitly create a tempfile for FastExcel to use
          workbook = FastExcel.open

          sheet_mappings.each do |sheet_mapping|
            name      = sheet_mapping.sheet.to_s
            worksheet = workbook.add_worksheet(name)
            rows      = array(payload[sheet_mapping.register])

            output.detail("Writing #{rows.length} row(s) to sheet: #{name}")

            rows.each { |row| worksheet.append_row(row) }
          end

          # readstring should close and remove the tmpfile for us:
          # https://github.com/Paxa/fast_excel/blob/master/lib/fast_excel.rb#L393
          value = workbook.read_string

          payload[register] = value
        end
      end
    end
  end
end
