module RedmineContactsAddCurrencies
  module CreateUserCurrencyFromParams
    def create_currency(params)
      @currency = {}
      fill_required_fields(params)
      fill_checkboxes(params)
      fill_customs_fields(params)
      @currency
    end

    def register_currency(hash)
      RedmineCrm::Currency.register(hash.values[0].deep_symbolize_keys!)
      RedmineCrm::Currency.new(hash.keys[0].to_sym)
    end

    def unregister_currency(id)
      RedmineCrm::Currency.unregister(id)
    end

    private
    def fill_required_fields(params)
      @currency['priority'] = params['priority'].to_i
      @currency['iso_code'] = params['iso_code'].upcase
      @currency['symbol'] = params['symbol']
      @currency['subunit'] = params['subunit']
      @currency['name'] = params['name']
    end

    def fill_checkboxes(params)
      if params['is_crypto'] && params['is_crypto'] == 'yes'
        @currency['is_crypto'] = true
      else
        @currency['is_crypto'] = false
      end
      if params['symbol_first'] && params['symbol_first'] == 'yes'
        @currency['symbol_first'] = true
      else
        @currency['symbol_first'] = false
      end
    end

    def fill_customs_fields(params)
      if params['alternate_symbols']
        @currency['alternate_symbols'] = params['alternate_symbols'].split(',').map{|e| e.strip}
      end
      @currency['subunit_to_unit'] = params['subunit_to_unit'].to_i if params['subunit_to_unit']
      @currency['html_entity'] = params['html_entity'] if params['html_entity']
      @currency['decimal_mark'] = params['decimal_mark'] if params['decimal_mark']
      @currency['thousands_separator'] = params['thousands_separator'] if params['thousands_separator']
      @currency['iso_numeric'] = params['iso_numeric'] if params['iso_numeric']
      @currency['smallest_denomination'] = params['smallest_denomination'].to_i if params['smallest_denomination']
    end
  end
end
