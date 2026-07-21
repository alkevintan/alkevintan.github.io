# frozen_string_literal: true

module Admin
  class MenuItemsController < BaseController
    before_action :set_menu_item, only: %i[edit update destroy]

    def index
      @menu_items = MenuItem.order(:menu, :position, :id)
    end

    def new
      @menu_item = MenuItem.new(menu: params[:menu].presence_in(MenuItem::MENU_LABELS.keys) || "header")
    end

    def create
      @menu_item = MenuItem.new(menu_item_params)
      if @menu_item.save
        redirect_to admin_menu_items_path, notice: "Menu link created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @menu_item.update(menu_item_params)
        redirect_to admin_menu_items_path, notice: "Menu link updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @menu_item.destroy
      redirect_to admin_menu_items_path, notice: "Menu link deleted.", status: :see_other
    end

    private

    def set_menu_item
      @menu_item = MenuItem.find(params[:id])
    end

    def menu_item_params
      params.require(:menu_item).permit(:menu, :label, :url, :position, :published)
    end
  end
end
