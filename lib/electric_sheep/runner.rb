require 'active_support/core_ext'

module ElectricSheep
  class Runner
    def initialize(options)
      @config = options[:config]
      @logger = options[:logger]
      @project = options[:project]
    end

    def run!
      @config.each_item do |project|
        if @project.nil? || @project == project.id
          execute_project(project)
        end
      end
    end

    protected

    def execute_project(project)
      project.benchmarked do
        @logger.info project.description ?
          "Executing \"#{project.description}\" (#{project.id})" :
          "Executing #{project.id}"
          project.each_item do |step|
            send("execute_#{executable_type(step)}", project, step)
          end
      end
    end

    def executable_type(executable)
      executable.class.name.underscore.split('/').last
    end

    def execute_shell(project, metadata)
      metadata.benchmarked do
        execute_commands project, metadata, Shell::LocalShell.new(@logger)
      end
    end

    def execute_remote_shell(project, metadata)
      metadata.benchmarked do
        execute_commands project, metadata, Shell::RemoteShell.new(
          @logger, @config.hosts.get(metadata.host), metadata.user,
          project.private_key
        )
      end
    end

    def execute_commands(project, shell_metadata, shell)
      shell.open!
      shell.mk_project_dir!(project)
      shell_metadata.each_item do |metadata|
        command = metadata.agent.new(project, @logger, shell,
          shell.project_dir(project), metadata )
        metadata.benchmarked do
          command.check_prerequisites
          command.perform
        end
      end
      shell.close!
    end

    def execute_transport(project, metadata)
      transport = metadata.agent.new(project, @logger, metadata, @config.hosts)
      metadata.benchmarked do
        transport.perform
      end
    end
  end
end
