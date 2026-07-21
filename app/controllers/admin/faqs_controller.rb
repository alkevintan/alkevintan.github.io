# frozen_string_literal: true

module Admin
  class FaqsController < BaseController
    before_action :set_faq, only: %i[edit update destroy]

    def index
      @faqs = Faq.order(:page, :position, :id)
    end

    def new
      @faq = Faq.new(page: params[:page].presence_in(Faq::PAGE_LABELS.keys) || "services")
    end

    def create
      @faq = Faq.new(faq_params)
      if @faq.save
        redirect_to admin_faqs_path, notice: "FAQ created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit; end

    def update
      if @faq.update(faq_params)
        redirect_to admin_faqs_path, notice: "FAQ updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @faq.destroy
      redirect_to admin_faqs_path, notice: "FAQ deleted.", status: :see_other
    end

    private

    def set_faq
      @faq = Faq.find(params[:id])
    end

    def faq_params
      params.require(:faq).permit(:page, :question, :answer, :position, :published)
    end
  end
end
