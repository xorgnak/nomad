
d = []; ARGF.argv.each {|e| d << %[-d #{e}]; }
`sudo certbot --agree-tos --email #{ENV['EMAIL']} -n --nginx #{d.join(' ')}`
