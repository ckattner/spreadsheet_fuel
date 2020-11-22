# frozen_string_literal: true

#
# Copyright (c) 2020-present, Blue Marble Payroll, LLC
#
# This source code is licensed under the MIT license found in the
# LICENSE file in the root directory of this source tree.
#

module SpreadsheetFuel
  module Modeling
    # Connects and maps a sheet name or index to a register name.
    # This can be used in either direction: sheet to register or register to sheet.
    class SheetMapping
      acts_as_hashable

      attr_reader :register, :sheet

      def initialize(register: Burner::DEFAULT_REGISTER, sheet: nil)
        @register = register.to_s
        @sheet    = sheet

        freeze
      end
    end
  end
end
