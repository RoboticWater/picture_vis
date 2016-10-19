import json
import urllib2
import urllib

api = 'https://api.flickr.com/services/rest/?method='
search = 'flickr.photos.search'
sizes = 'flickr.photos.getSizes'
info = 'flickr.photos.getInfo'
key = '8c40881bcc542010baa4753f7e662c50'
settings = '&format=json&nojsoncallback=1&api_key=' + key

output = {}

page_prefix = 'http://flickr.com/photo.gne?id='

req = urllib2.Request(api + search + settings + '&text=LMC2700')
res = urllib2.urlopen(req)
data = json.load(res)

pages = data['photos']['pages']

print api + search + settings + '&text=LMC2700'

for page in range(pages):
    req = urllib2.Request(api + search + settings + '&text=LMC2700' + '&page=' + str(page + 1))
    res = urllib2.urlopen(req)
    data = json.load(res)

    photos = data['photos']['photo']

    for photo in photos:
        print photo['id']
        req = urllib2.Request(api + sizes + settings + '&photo_id=' + photo['id'])
        res = urllib2.urlopen(req)
        data = json.load(res)
        try:
            urllib.urlretrieve(data['sizes']['size'][1]['source'], photo['id'] + '.jpg')
        except IOError, e:
            print e
        req = urllib2.Request(api + info + settings + '&photo_id=' + photo['id'])
        res = urllib2.urlopen(req)
        data = json.load(res)
        date = data['photo']['dates']['taken']
        tags = [tag['_content'] for tag in data['photo']['tags']['tag']]
        output[photo['id']] = {
            'user': data['photo']['owner']['nsid'],
            'time': [int(date[0:4]), int(date[5:7]), int(date[8:10]), int(date[11:13]), int(date[14:16]), int(date[17:19])],
            'tags': tags,
        }

with open('output.json', 'w') as f:
    json.dump(output, f)
