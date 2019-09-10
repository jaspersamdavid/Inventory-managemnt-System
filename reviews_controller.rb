class ReviewsController < ApplicationController
  before_action :set_review, only: [:show, :edit, :update, :destroy]

  def index
    @reviews = current_user.reviews
    # authorize(@reviews)
  end

  def show
  end

  def new
    @review = Review.new
    authorize(@review)
  end

  def edit
    authorize(@review)
  end

  def create
    @current_user = current_user
    review_params_user = review_params.merge!(user_id: @current_user.id )
    @review = Review.new(review_params_user)
    authorize(@review)
    if @review.save
      redirect_to :root, notice: 'Review was successfully created.'
    else
      render :new
    end
  end

  def update
    authorize(@review)
    respond_to do |format|
      if @review.update(review_params)
        format.html { redirect_to reviews_path, notice: 'Review was successfully updated.' }
        format.json { render :show, status: :ok, location: @review }
      else
        format.html { render :edit }
        format.json { render json: @review.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize(@review)
    binding.pry

    @review.destroy
    respond_to do |format|
      format.html { redirect_to reviews_url, notice: 'Review was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_review
      @review = Review.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def review_params
      params.require(:review).permit(:rating, :body, :product_id, :supplier_id, :user_id)
    end
end
