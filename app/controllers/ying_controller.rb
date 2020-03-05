class YingController < ApplicationController
  def meizhuang
    ks = []
    page = rand(1000)
    @products = MeizhuangProduct.select(:id, :title, :pict_url, :is_tmall, :price, :o_price, :volume, :keywords).order(:id).offset(page * 40).limit(40)
    @products.each do |pro|
      ks += pro.keywords.split(',')
    end
    @links = ks.uniq.sample(30).map{|k| {url: "/zhekou/#{URI.encode_www_form_component(k)}/", anchor: k}}
  end

  def meizhuang_product
    @product = MeizhuangProduct.where(id: params[:id].to_i, status: 1).take
    if @product.nil?
      not_found
      return
    end
    ks = @product.keywords.split(',')
    @products = MeizhuangProduct.where("id > ? and status = 1", @product.id).select(:id, :title, :pict_url, :is_tmall, :price, :o_price, :volume, :keywords).order(:id).limit(20)
    @products.each do |pro|
      ks += pro.keywords.split(',')
    end
    @links = ks.uniq.sample(30).map{|k| {url: "/zhekou/#{URI.encode_www_form_component(k)}/", anchor: k}}
    @path = "/meizhuang/#{@product.id}/"
    @product_path = "/meizhuang/"
    render "tb_pc_static_product"
  end

  def peishi
    ks = []
    page = rand(1000)
    @products = PeishiProduct.select(:id, :title, :pict_url, :is_tmall, :price, :o_price, :volume, :keywords).order(:id).offset(page * 40).limit(40)
    @products.each do |pro|
      ks += pro.keywords.split(',')
    end
    @links = ks.uniq.sample(30).map{|k| {url: "/zhekou/#{URI.encode_www_form_component(k)}/", anchor: k}}
  end

  def peishi_product
    @product = PeishiProduct.where(id: params[:id].to_i, status: 1).take
    if @product.nil?
      not_found
      return
    end
    ks = @product.keywords.split(',')
    @products = PeishiProduct.where("id > ? and status = 1", @product.id).select(:id, :title, :pict_url, :is_tmall, :price, :o_price, :volume, :keywords).order(:id).limit(20)
    @products.each do |pro|
      ks += pro.keywords.split(',')
    end
    @links = ks.uniq.sample(30).map{|k| {url: "/zhekou/#{URI.encode_www_form_component(k)}/", anchor: k}}
    @path = "/peishi/#{@product.id}/"
    @product_path = "/peishi/"
    render "tb_pc_static_product"
  end
end
