# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module SpreadsheetFuel
  module Library
    module Deserialize
      # Read in the input register and parse it as a Microsoft Excel Open XML Spreadsheet.
      # Sheets can be specified and mapped to registers using the sheet_mappings option.
      # If not sheet_mappings exist, then the default functionality will be to parse the
      # default sheet and overwrite the input register with the sheet's parsed contents.
      # The parsed content for each sheet will be a two-dimensional array where each row is in
      # its own second level array so that cell B3 would be at index [2][1].
      #
      # Expected Payload[register] input: XLSX blob of data.
      # Payload[register|sheet_mappings.register] output: array of arrays.
      class Xlsx < Burner::JobWithRegister
        attr_reader :sheet_mappings

        def initialize(name: '', register: Burner::DEFAULT_REGISTER, sheet_mappings: nil)
          super(name: name, register: register)

          @sheet_mappings = Modeling::SheetMapping.array(sheet_mappings)

          # If no sheets/register mappings are specified then lets just use the default
          # sheet and the current register.
          if @sheet_mappings.empty?
            @sheet_mappings << Modeling::SheetMapping.new(register: register)
          end

          freeze
        end

        def perform(output, payload)
          output.detail("Reading spreadsheet in register: #{register}")

          value = payload[register]
          io    = StringIO.new(value)
          book  = Roo::Excelx.new(io)

          sheet_mappings.each do |sheet_mapping|
            rows    = sheet_mapping.sheet ? book.sheet(sheet_mapping.sheet).to_a : book.to_a
            sheet   = friendly_sheet(sheet_mapping.sheet)
            message = <<~MESSAGE
              Loading #{rows.length} record(s) from #{sheet} into register: #{register}
            MESSAGE

            output.detail(message)

            payload[sheet_mapping.register] = rows
          end
        end

        private

        def friendly_sheet(name)
          name ? "sheet: #{name}" : 'the default sheet'
        end
      end
    end
  end
end
