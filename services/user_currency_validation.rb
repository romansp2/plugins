module RedmineContactsAddCurrencies
  module UserCurrenciesValidation
    def check_for_required_param(params)
      messages = []
      [params['priority'], params['iso_code'],
       params['name'], params['symbol'], params['subunit']].each do |param|
        messages << check_params_present(param)
      end
      return messages.delete_if {|i| i == 'Ok'} unless messages.delete_if {|i| i == 'Ok'}.empty?
      unless params['priority'].to_i.is_a? Integer || params['priority'] > 0 || params['priority'] < 100
        return messages << 'Неверно указан приоритет'
      end
      return messages << 'Неверно указан iso_code' if params['iso_code'].length > 3
      if !params['iso_code'].scan(/^[a-zA-Z0-9]+$/).any? || !params['name'].scan(/^[a-zA-Z0-9]+$/).any? ||
          !params['subunit'].scan(/^[a-zA-Z0-9]+$/).any?
        return messages << 'Допускаются только латинские буквы и цифры'
      end
      messages
    end

    def check_separators(params)
      messages = []
      [params['thousands_separator'], params['decimal_mark']].each {|param| messages << check_params_present(param)}
      return messages.delete_if {|i| i == 'Ok'} unless messages.delete_if {|i| i == 'Ok'}.empty?
      messages.empty? ? '' : messages
    end

    private

    def check_params_present(param)
      if param
        if !param.empty?
          'Ok'
        else
          'Проверьте правильность заполнения полей'
        end
      else
        'Проверьте правильность заполнения полей'
      end
    end
  end
end
