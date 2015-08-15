#!/bin/env ruby
# encoding: utf-8

require 'scraperwiki'
require 'nokogiri'
require 'open-uri'
require 'uri'

require 'pry'
require 'open-uri/cached'
OpenURI::Cache.cache_path = '.cache'

def noko_for(url)
  Nokogiri::HTML(open(url).read) 
end

def scrape(url)
  noko = noko_for(url)
  h3 = noko.xpath('.//h3[contains(.,"Aktuell Period")]')
  h3.xpath('following::li | following::h3').slice_before { |e| e.name == 'h3' }.first.each do |li|
    li.css('a').each do |a|
      next if a.attr('class') == 'new'
      data = { 
        name: a.text.strip,
        wikipedia__lu: a.attr('title'),
      }
      ScraperWiki.save_sqlite([:wikipedia__lb], data)
    end
  end
end

scrape('https://lb.wikipedia.org/wiki/Chamber')
