require 'time'

def get_pids(process_name)
  `pgrep -f #{process_name}`.split("\n").map(&:to_i)
end

def read_proc_stat(pid)
  stat_path = "/proc/#{pid}/stat"
  if File.exist?(stat_path)
    data = File.read(stat_path).split
    utime = data[13].to_i  # 14th field
    stime = data[14].to_i  # 15th field
    return utime, stime
  else
    return 0, 0
  end
end

def read_proc_io(pid)
  io_path = "/proc/#{pid}/io"
  if File.exist?(io_path)
    rchar = File.readlines(io_path).find { |line| line.start_with?("rchar:") }
    return rchar.split(":")[1].strip.to_i
  else
    return 0
  end
end

def get_etimes(pid)
  etimes = `ps -p #{pid} -o etimes=`.strip
  etimes.empty? ? nil : etimes.to_i
end

def monitor_processes(process_names, interval = 5)
  all_pids = {}
  process_names.each do |name|
    all_pids[name] = get_pids(name)
    puts "Process #{name} (PIDs: #{all_pids[name].join(', ')})"
  end


  loop do
    begin
    puts "Time\t\tProcess\t\tutime\tstime\trchar\tetimes(s)"
      process_names.each do |name|
        pids = get_pids(name)
        next if pids.empty?
        utime_sum = 0
        stime_sum = 0
        rchar_sum = 0
        etimes_list = []
        pids.each do |pid|
          ut, st = read_proc_stat(pid)
          utime_sum += ut
          stime_sum += st
          rchar_sum += read_proc_io(pid)
          et = get_etimes(pid)
          etimes_list << et if et
        end
        etimes_str = etimes_list.empty? ? "-" : "#{etimes_list.min}/#{etimes_list.max}"
        puts "#{Time.now.strftime('%H:%M:%S')}\t#{sprintf('%-12s', name)}\t#{utime_sum}\t#{stime_sum}\t#{sprintf('%-12s', rchar_sum)}\t#{etimes_str}"
      end
      sleep(interval)
    rescue => e
      puts e.message
      break
    end
  end
end

# 実行
monitor_processes(["martin", "caddy", "cloudflared"], 180)
