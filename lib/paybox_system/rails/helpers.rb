module Paybox
  module System
    module Rails
      module Integrity
        class Error < StandardError; end

        protected
        def check_paybox_integrity!
          raise Error, "Bad response" unless params[:error].present? && params[:sign].present?

          request_fullpath = request.fullpath

          request_params = request_fullpath[request_fullpath.index("?")+1..request_fullpath.index("&sign")-1]
          request_sign = request_fullpath[request_fullpath.index("&sign")+6..-1]

          raise Error, "Bad Paybox integrity test" unless Paybox::System::Base.check_response?(request_params, request_sign)
        end
      end

      module Helpers
        def paybox_hidden_fields(opts = {})
          out = ""
          formatted_options = Paybox::System::Base.hash_form_fields_from(opts)

          formatted_options.each do |o, v|
            out << hidden_field_tag(o, Rack::Utils.escape(v))
            out << "\n"
          end

          out.html_safe
        end
      end
    end
  end
end
