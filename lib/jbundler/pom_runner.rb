require 'maven/ruby/maven'
module JBundler
  
  class PomRunner

    def initialize( config )
      @config = config
    end

    def method_missing( m, *args )
      result = @config[ m ] || @config[ m.to_s ] 
      result.nil? ? super : result
    end

    def maven
      @m ||= 
        begin
          m = Maven::Ruby::Maven.new
          m.property( 'base.dir', File.expand_path( basedir ) )
          m.property( 'work.dir', File.expand_path( workdir ) ) if workdir
          m.property( 'verbose', debug || verbose )
          m.options[ '-q' ] = nil if !debug and !verbose
          m.options[ '-e' ] = nil if !debug and verbose
          m.options[ '-X' ] = nil if debug
          m.verbose = debug
          m
        end
    end

    def basedir
      File.expand_path( '.' )
    end

    def workdir
       @config[ 'workdir' ]
    end

    def work_dir
      # needs default here
      workdir || 'pkg'
    end

    def debug
       @config[ 'debug' ] || false
    end

    def verbose
       @config[ 'verbose' ] || false
    end

    def clean?
       @config[ 'clean' ] || false      
    end

    def pom_file
      raise 'overwrite this method'
    end

    def exec( *args )
      maven.options[ '-f' ] ||= pom_file
      args.unshift :clean if clean?
      maven.exec( *args )
    end
  end
end
