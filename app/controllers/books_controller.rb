class BooksController < ApplicationController
  before_action :set_book, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!

  # GET /books
  # GET /books.json
  # gets list of all the books and users and transactions
  # Request: GET
  def index
    @books = Book.all
    $users = User.all
    $transactions= Transaction.all
  end

  # GET /books/1
  # GET /books/1.json
  def show
  end

  # GET /books/new
  # creates a new book
  # Request: GET
  def new
    @book = Book.new
  end

  # GET /books/1/edit
  def edit
  end

  # POST /books
  # POST /books.json
  #Creates new book
  # Request: POST
  def create
    @book = Book.new(book_params)
    @book.user = current_user
    respond_to do |format|
      if @book.save
        format.html { redirect_to @book, notice: 'Book was successfully created.' }
        format.json { render :show, status: :created, location: @book }
      else
        format.html { render :new }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /books/1
  # PATCH/PUT /books/1.json
  # Updates the table books.
  # Request: PATCH/PUT
  def update
    respond_to do |format|
      if @book.update(book_params)
        format.html { redirect_to @book, notice: 'Book was successfully updated.' }
        format.json { render :show, status: :ok, location: @book }
      else
        format.html { render :edit }
        format.json { render json: @book.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /books/1
  # DELETE /books/1.json
  # Deletes the posts
  # Request: DELETE
  def destroy
    @book.destroy
    respond_to do |format|
      format.html { redirect_to books_url, notice: 'Book was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # Places requests and creates a new transactions row and updates the columns
  # Request: PATCH
  def update_requested_by
     @book=Book.find(params[:id])
     k=0
     $transactions.each do |transaction|
       if transaction.requested_by_id==current_user.id and transaction.book_id==@book.id and (transaction.status==3 or (transaction.status==1 and transaction.returned=false))
         k=1
       end
     end
     @transaction=Transaction.new
    if k==0
      @transaction.update_attribute(:book_id, @book.id)
      @transaction.update_attribute(:requested_by, current_user.name )
      @transaction.update_attribute(:requested_by_id, current_user.id )
      @transaction.update_attribute(:requested, true)
      @transaction.update_attribute(:status, 3)
      redirect_to @book, notice: "Book issue request is successfully placed"
     else
      redirect_to books_url, notice: "You have already requested this book"
     end
  end

# fetches all the books from the book table
# Request: GET
  def mybooks
   @books = Book.all
 end

 def requests
  @books = Book.all
end

def myrequests
 @books = Book.all
end

def approved
 @books = Book.all
end

def rejected
 @books = Book.all
end

# Once the librarian approves the book, the columns in the transactions table gets updated to contain that information
# Request: PATCH
def update_status_approved
  @transaction=Transaction.find(params[:id])
  @book=Book.find(@transaction.book_id)
  @transaction.update_attribute(:issued_to, @transaction.requested_by )
  @transaction.update_attribute(:issued_to_id, @transaction.requested_by_id )
  @transaction.update_attribute(:issue_date, Date.today)
  @transaction.update_attribute(:status, 1)
  @book.update_attribute(:quantity, @book.quantity-1)
  redirect_to @book, notice: "Book approved to the student"
end

# Once the librarian rejects the book, the columns in the transactions table gets updated to contain that information
# Request: PATCH
def update_status_rejected
  @transaction=Transaction.find(params[:id])
  @book=Book.find(@transaction.book_id)
  @transaction.update_attribute(:status, 2)
  redirect_to @book, notice: "Book request is rejected"
end

# When the students returns the book, the returned column becomes true
# Request: PATCH
def return
  @transaction=Transaction.find(params[:id])
  @book=Book.find(@transaction.book_id)
  @transaction.update_attribute(:returned, true)
  @transaction.update_attribute(:return_date, Date.today)
  @book.update_attribute(:quantity, @book.quantity+1)
  redirect_to @book, notice: "Book is returned"
end


def mytransactions
  @books=Book.all
end

# When the download csv is clicked, it generates the transaction.csv file
def transactions
  @books=Book.all
  respond_to do |format|
    format.html
    format.csv do
     headers['Content-Disposition'] = "attachment; filename=\"transactions.csv\""
     headers['Content-Type'] ||= 'text/csv'
    end
  end
end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_book
      @book = Book.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def book_params
      params.require(:book).permit(:title, :author, :description, :quantity, :isbn, images: [])
    end
end
