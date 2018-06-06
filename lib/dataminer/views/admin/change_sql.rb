# frozen_string_literal: true

module DM
  module Admin
    class ChangeSql
      def self.call(id, form_values = nil, form_errors = nil)
        # ui_rule = UiRules::Compiler.new(:user, :edit, id: id, form_values: form_values)
        # rules   = ui_rule.compile
        # report = lookup_admin_report(id) # TODO: create a repo for this...
        repo    = DataminerApp::ReportRepo.new
        report  = repo.lookup_admin_report(id)
        obj     = OpenStruct.new
        obj.id  = id
        obj.sql = report.sql
        rules   = { fields: { id: { renderer: :hidden },
                              sql: { renderer: :textarea,
                                     cols: 60,
                                     rows: 25 } },
                    name: 'report' }

        layout = Crossbeams::Layout::Page.build(rules) do |page|
          # page.form_object ui_rule.form_object
          page.form_object obj
          page.form_values form_values
          page.form_errors form_errors
          page.form do |form|
            form.action "/dataminer/admin/#{id}/save_new_sql"
            # form.remote!
            form.method :update
            form.add_field :id
            form.add_field :sql
          end
        end

        layout
      end
    end
  end
end
