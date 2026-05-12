# frozen_string_literal: true

module Djbdns
  module ServiceUnitHelpers
    private

    def service_group_gid
      platform_family?('debian') ? 65_534 : 99
    end

    def systemd_unit_name(service_name)
      "#{service_name}.service"
    end

    def manage_djbdns_service(service_name:, exec_start:, environment:, working_directory:, limit_data: nil, limit_nofile: nil, standard_input: nil)
      service_content = {
        Type: 'simple',
        ExecStart: exec_start,
        WorkingDirectory: working_directory,
        Environment: environment.map { |key, value| "#{key}=#{value}" },
        Restart: 'always',
        StandardOutput: 'journal',
        StandardError: 'journal',
      }

      service_content[:LimitDATA] = limit_data if limit_data
      service_content[:LimitNOFILE] = limit_nofile if limit_nofile
      service_content[:StandardInput] = standard_input if standard_input

      systemd_unit systemd_unit_name(service_name) do
        content(
          Unit: {
            Description: "djbdns #{service_name} service",
            After: 'network.target',
          },
          Service: service_content,
          Install: {
            WantedBy: 'multi-user.target',
          }
        )
        action [:create, :enable]
        notifies :restart, "service[#{service_name}]", :delayed
      end

      service service_name do
        action [:enable, :start]
      end
    end

    def remove_djbdns_service(service_name:, service_dir:)
      unit_name = systemd_unit_name(service_name)

      service service_name do
        action [:stop, :disable]
        only_if { ::File.exist?("/etc/systemd/system/#{unit_name}") }
      end

      systemd_unit unit_name do
        action :delete
      end

      directory service_dir do
        recursive true
        action :delete
      end
    end
  end
end
