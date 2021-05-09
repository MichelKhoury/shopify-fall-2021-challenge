module ImagesHelper
    # find all images containing one of the tags
    def find_images tag_array
        results = Array.new

        @images.each do |saved_image|
            is_found = false
            tag_array.each do |tag|
                if saved_image.tags.downcase.include?(tag.downcase) && !is_found
                    results.push(saved_image)
                    is_found = true
                end
            end
        end
    
        return results
    end

    # call google vision API to fetch tags
    def fetch_tags params
        encoded_image = Base64.strict_encode64(params[:image_file].tempfile.read)
        api_key = ENV["GOOGLE_API_KEY"]
        api_url = "https://vision.googleapis.com/v1/images:annotate?key=#{api_key}"

        body = {
        requests: [{
            image: {
            content: encoded_image
            },
            features: [
            {
                type: 'LABEL_DETECTION', maxResults: 10
            }
            ]
        }]
        }
        # Send request.
        uri = URI.parse(api_url)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        request = Net::HTTP::Post.new(uri.request_uri)
        request["Content-Type"] = "application/json"
        response = https.request(request, body.to_json)

        # Add the generated labels to the list of tag
        JSON.parse(response.body)["responses"].each do |res|
            res["labelAnnotations"].each do |tag|
                @image.tags.prepend(tag["description"], ",")
            end
        end
        @image.tags = @image.tags.delete_suffix(',')
    end
end