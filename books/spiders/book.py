import scrapy

class BookSpider(scrapy.Spider):
    name = "book"

    def start_requests(self) :
        yield scrapy.Request("data:,dummy", callback=self.parse, dont_filter=True)

    def parse(self, response):
        return {"name":"alchemist"}
