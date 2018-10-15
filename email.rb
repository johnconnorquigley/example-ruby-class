class Email
     require 'mail'

     def self.get_email_server_received_lines(email)
         @keywords = ['from', 'by', 'with', 'id', 'via', 'for']
         unless email.class.to_s == 'Mail::Message'
             email = Mail.read(email)
         end
         received_entries = get_received_entries_from_email(email)
     end

     def self.get_received_entries_from_email(email)
         received_entries = []
         email.header["Received"].each do |pre_parse_received_entry|
             time = DateTime.parse(pre_parse_received_entry.field.date_time.to_s)
             data_array = pre_parse_received_entry.field.info.split(' ')
             received_entries << ReceivedLine.new(get_received_entry(data_array, time))
         end
         received_entries
     end

     def self.get_received_entry(data_array, time)
         entry = received_entry_data
         current_keyword = 'from'
         data_array.each do |string|
             if @keywords.include?(string)
                 current_keyword = string
             else
                 entry[current_keyword.to_sym] << string
             end
         end
         entry[:time] = time.utc
         entry
     end

     def self.received_entry_data
         return {
             from: [],
             by: [],
             with: [],
             id: [],
             via: [],
             for: [],
             time: nil
         }
     end

  class ReceivedLine < HashManager
 		def initialize(entity)
       		super(self.prepare(entity))
     	end

 		def prepare(entity)
 			hash = {}
 			hash['from'] = entity[:from]
             hash['by'] = entity[:by]
             hash['with'] = entity[:with]
             hash['id'] = entity[:id]
             hash['via'] = entity[:for]
             hash['time'] = entity[:time]
 			return hash
 		end
 	end
  
 end
