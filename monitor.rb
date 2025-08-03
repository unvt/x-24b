require 'time'

def get_pid(process_name)
  pid = `pgrep -f #{process_name}`.split("\n").first
  if pid.nil? || pid.empty?
    puts "Process #{process_name} not found."
    return nil
  end
  pid.to_i
end

def read_proc_stat(pid)
  stat_path = "/proc/#{pid}/stat"
  if File.exist?(stat_path)
    data = File.read(stat_path).split
    utime = data[13].to_i  # 14th field
    stime = data[14].to_i  # 15th field
    return utime, stime
  else
    raise "Stat file for PID #{pid} not found."
  end
end

def read_proc_io(pid)
  io_path = "/proc/#{pid}/io"
  if File.exist?(io_path)
    rchar = File.readlines(io_path).find { |line| line.start_with?("rchar:") }
    return rchar.split(":")[1].strip.to_i
  else
    raise "IO file for PID #{pid} not found."
  end
end

def monitor_processes(process_names, interval = 5)
  pids = process_names.map { |name| [name, get_pid(name)] }.to_h
  pids.each { |name, pid| puts "Process #{name} (PID: #{pid || 'not found'})" }

  puts "Time\t\tProcess\t\tutime\tstime\trchar"
  loop do
    begin
      pids.each do |name, pid|
        next unless pid

        utime, stime = read_proc_stat(pid)
        rchar = read_proc_io(pid)
        puts "#{Time.now.strftime('%H:%M:%S')}\t#{name}\t\t#{utime}\t#{stime}\t#{rchar}"
      end
      sleep(interval)
    rescue => e
      puts e.message
      break
    end
  end
end

# 実行
monitor_processes(["martin", "caddy", "cloudflared"], 5)
